# spec/factories/products.rb
FactoryBot.define do
  factory :product do
    sequence(:sku) { |n| "PROD-J#{n.to_s.rjust(3, '0')}" }
    sequence(:name) { |n| "Product #{('A'..'Z').to_a[n % 26]}" }
    description { "Description for #{name}" }
    price_amount { [ 10.0, 25.5, 59.99, 123.46, 199.99 ].sample }
    price_currency { "USD" }
    tax_amount { (price_amount.to_f * 0.1).round(2) }
    tax_currency { "USD" }
    stock { (1..50).to_a.sample }
  end
end
