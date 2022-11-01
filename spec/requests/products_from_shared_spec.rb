# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/products', type: :request do
  let(:valid_attributes) do
    attributes_for(:product)
  end

  let(:invalid_attributes) do
    attributes_for(:product, name: nil)
  end

  let(:new_attributes) do
    { name: 'OtherName' }
  end

  include_examples 'make request', Product
end
