
# Define Product model
class Product < ActiveRecord::Base
  validates :sku, :name, :price_amount, :price_currency, :stock, presence: true
end
