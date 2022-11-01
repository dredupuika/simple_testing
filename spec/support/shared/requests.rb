RSpec.shared_examples 'make request' do |model, options = {}|
  only = options.fetch :only, nil
  except = options.fetch :except, []
  test_for = only || (%i[index show new edit create update destroy] - except)

  create_redirect = options.fetch :create_redirect, :show
  update_redirect = options.fetch :update_redirect, :show
  destroy_redirect = options.fetch :destroy_redirect, :index
  test_invalid = options.fetch :test_invalid, true
  scope = options.fetch :scope, nil

  model_name = model.model_name.name.underscore
  factory_name = options.fetch :factory_name, model_name.to_sym

  find_by = options.fetch :find_by, :id

  collection_url = [scope, model_name.pluralize, 'url'].compact.join('_')
  show_url = [scope, model_name, 'url'].compact.join('_')
  edit_url = ['edit', scope, model_name, 'url'].compact.join('_')
  new_url = ['new', scope, model_name, 'url'].compact.join('_')

  if options[:shallow_route]
    shallow_parent = options[:shallow_route].model_name.name.underscore
    parent_id = "#{shallow_parent}_id".to_sym

    collection_url = [scope, shallow_parent, model_name.pluralize, 'url'].compact.join('_')
    new_url = ['new', scope, shallow_parent, model_name, 'url'].compact.join('_')
  end

  if test_for.include? :index
    describe 'GET /index' do
      it 'renders a successful response' do
        resource = create(factory_name, valid_attributes)
        default_params = {}
        default_params[parent_id] = resource.send(shallow_parent).id if options[:shallow_route]
        get send(collection_url, default_params)
        expect(response).to be_successful
      end
    end
  end

  if test_for.include? :show
    describe 'GET /show' do
      it 'renders a successful response' do
        resource = create(factory_name, valid_attributes)
        get send(show_url, resource.send(find_by))
        expect(response).to be_successful
      end
    end
  end

  if test_for.include? :new
    describe 'GET /new' do
      it 'renders a successful response' do
        default_params = {}
        if options[:shallow_route]
          parent_resource = instance_variable_get("@#{shallow_parent}") || create(shallow_parent)
          default_params[parent_id] = parent_resource.id
        end
        get send(new_url, default_params)
        expect(response).to be_successful
      end
    end
  end

  if test_for.include? :edit
    describe 'GET /edit' do
      it 'render a successful response' do
        resource = create(factory_name, valid_attributes)
        get send(edit_url, resource.send(find_by))
        expect(response).to be_successful
      end
    end
  end

  if test_for.include? :create
    describe 'POST /create' do
      context 'with valid parameters' do
        it "creates a new #{model_name}" do
          default_params = {}
          if options[:shallow_route]
            parent_resource = instance_variable_get("@#{shallow_parent}") || create(shallow_parent)
            default_params[parent_id] = parent_resource.id
          end
          expect do
            post send(collection_url, default_params), params: { model_name.to_sym => valid_attributes }
          end.to change(model, :count).by(1)
        end

        it "redirects to the created #{model_name} #{create_redirect}" do
          default_params = {}
          if options[:shallow_route]
            parent_resource = instance_variable_get("@#{shallow_parent}") || create(shallow_parent)
            default_params[parent_id] = parent_resource.id
          end
          post send(collection_url, default_params), params: { model_name.to_sym => valid_attributes }
          redirect_path = case create_redirect
                          when String
                            eval(create_redirect)
                          when :index
                            send(collection_url, default_params)
                          when :edit
                            send(edit_url, model.last.send(find_by))
                          when :show
                            send(show_url, model.last.send(find_by))
                          end

          expect(response).to redirect_to(redirect_path)
        end
      end

      if test_invalid
        context 'with invalid parameters' do
          it "does not create a new #{model_name}" do
            default_params = {}
            if options[:shallow_route]
              parent_resource = instance_variable_get("@#{shallow_parent}") || create(shallow_parent)
              default_params[parent_id] = parent_resource.id
            end
            expect do
              post send(collection_url, default_params), params: { model_name.to_sym => invalid_attributes }
            end.to change(model, :count).by(0)
          end

          it "renders a successful response (i.e. to display the 'new' template)" do
            default_params = {}
            if options[:shallow_route]
              parent_resource = instance_variable_get("@#{shallow_parent}") || create(shallow_parent)
              default_params[parent_id] = parent_resource.id
            end
            post send(collection_url, default_params), params: { model_name.to_sym => invalid_attributes }
            expect(response).to have_http_status(:unprocessable_entity)
          end
        end
      end
    end
  end

  if test_for.include? :update
    describe 'PATCH /update' do
      context 'with valid parameters' do
        it "updates the requested #{model_name}" do
          resource = create(factory_name, valid_attributes)
          patch send(show_url, resource.send(find_by)), params: { model_name.to_sym => new_attributes }
          resource.reload
          new_attributes.each_key do |k|
            expect(resource[k]).to eql new_attributes[k]
          end
        end

        it "redirects to the #{model_name} #{update_redirect}" do
          resource = create(factory_name, valid_attributes)
          patch send(show_url, resource.send(find_by)), params: { model_name.to_sym => new_attributes }
          resource.reload
          redirect_path = case update_redirect
                          when String
                            default_params = {}
                            default_params[parent_id] = resource.send(shallow_parent).id if options[:shallow_route]
                            eval(update_redirect)
                          when :index
                            default_params = {}
                            default_params[parent_id] = resource.send(shallow_parent).id if options[:shallow_route]
                            send(collection_url, default_params)
                          when :edit
                            send(edit_url, resource.send(find_by))
                          when :show
                            send(show_url, resource.send(find_by))
                          end
          expect(response).to redirect_to(redirect_path)
        end
      end
      if test_invalid
        context 'with invalid parameters' do
          it "renders a successful response (i.e. to display the 'edit' template)" do
            resource = create(factory_name, valid_attributes)
            patch send(show_url, resource.send(find_by)), params: { model_name.to_sym => invalid_attributes }
            expect(response).to have_http_status(:unprocessable_entity)
          end
        end
      end
    end
  end

  if test_for.include? :destroy
    describe 'DELETE /destroy' do
      it "destroys the requested #{model_name}" do
        resource = create(factory_name, valid_attributes)
        expect do
          delete send(show_url, resource.send(find_by))
        end.to change(model, :count).by(-1)
      end

      it "redirects to the #{model_name} list" do
        resource = create(factory_name, valid_attributes)
        delete send(show_url, resource.send(find_by))
        default_params = {}
        default_params[parent_id] = resource.send(shallow_parent).id if options[:shallow_route]
        redirect_path = case destroy_redirect
                        when String
                          eval(destroy_redirect)
                        when :index
                          send(collection_url, default_params)
                        end

        expect(response).to redirect_to(redirect_path)
      end
    end
  end
end
