# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Home', type: :request do
  describe 'GET /index' do
    context 'with no data' do
      it 'returns http success' do
        get root_path
        expect(response).to have_http_status(:success)
      end
    end

    context 'with data' do
      before do
        create_list(:product, 5)
      end

      it 'returns http success' do
        get root_path
        expect(response).to have_http_status(:success)
      end
    end
  end
end
