# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MegaApiService do
  let(:object) { described_class.new }

  before do
    allow(object).to receive(:data).and_return(
      [
        { id: 1, full_name: 'First', total_price: 123 },
        { id: 2, full_name: 'Second', total_price: 321 }
      ]
    )
  end

  describe '#index' do
    subject { object.index }

    it 'responds with' do
      expect(subject).to contain_exactly(
        { name: 'First', price: 123 },
        { name: 'Second', price: 321 }
      )
    end
  end

  describe '#item_by_id' do
    subject { object.item_by_id(1) }

    it 'responds with' do
      expect(subject).to include({ name: 'First', price: 123 })
    end
  end
end
