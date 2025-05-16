# spec/factories/products.rb
FactoryBot.define do
  factory :product do
    sequence(:id) { |n| n }
    sequence(:sku) { |n| "PROD-#{n.to_s.rjust(3, '0')}" }
    sequence(:name) { |n| "Product #{('A'..'Z').to_a[n % 26]}" }
    description { "Description for #{name}" }
    price_amount { [ 10.0, 25.5, 59.99, 123.46, 199.99 ].sample }
    price_currency { "USD" }
    tax_amount { (price_amount * 0.1).round(2) }
    tax_currency { "USD" }
    stock { [ 0, 40, 75, 120, 180, 250, 300, 500 ].sample }
  end
end
