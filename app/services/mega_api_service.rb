# frozen_string_literal: true

class MegaApiService
  API_PATH = 'https://example.com/api'

  def index
    data.map { |row| parse_row(row) }
  end

  def item_by_id(id)
    row = data.find { |r| r[:id] == id }
    parse_row(row)
  end

  private

  def parse_row(row)
    {
      name: row[:full_name],
      price: row[:total_price]
    }
  end

  def data
    JSON.parse(load(API_PATH))
  end

  def load(path)
    raise 'Broken Internet connection'
  end
end
