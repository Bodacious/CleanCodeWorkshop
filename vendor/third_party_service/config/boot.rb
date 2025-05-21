

# frozen_string_literal: true
require 'sqlite3'
require 'active_record'
require 'app'

# Establish DB connection
ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: 'db/third_party_service.sqlite3'
)

# Create products table if it doesn't exist
ActiveRecord::Schema.define do
  create_table :products, force: true do |t|
    t.string  :sku
    t.string  :name
    t.text    :description
    t.string  :price_amount
    t.string  :price_currency
    t.string  :tax_amount
    t.string  :tax_currency
    t.integer :stock
  end
end unless ActiveRecord::Base.connection.table_exists?(:products)

# Sinatra app
class ThirdPartyService < Sinatra::Base
  use Resources::Products
end