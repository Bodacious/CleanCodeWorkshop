require "test_helper"

class ProductTest < ActiveSupport::TestCase
  test ".database_file= sets the database file" do
    Product.database_filepath = "file-path"
    assert_equal Pathname.new("file-path"), Product.database_filepath
  end

  test ".all returns all products" do
    db_data = <<~YAML
      1-product:
        id: 1
        name: Product one
      2-product:
        id: 2
        name: Product two
    YAML
    with_temp_db(db_data) do |db|
      Product.database_filepath = db.path
      products = Product.all
      assert_equal 2, products.size
      assert_equal "Product one", products.first.name
      assert_equal "Product two", products.last.name
    end
  end

  test ".max returns the maximum value for a given attribute" do
    with_temp_db do |file|
      Product.database_filepath = file.path
      Product.new(id: 1, price_amount: 5.0).save
      Product.new(id: 2, price_amount: 10.0).save
      assert_equal 10.0, Product.max(:price_amount)
    end
  end

  test ".find returns the product with the given id" do
    with_temp_db do |file|
      Product.database_filepath = file.path
      product = Product.new(id: 1, name: "Product A")
      product.save
      found_product = Product.find(1)
      assert_equal product.name, found_product.name
    end
  end

  test ".where returns products that match the given filters" do
    temp_db_data = <<~YAML
      1-product:
        id: 1
        name: Product one
      2-product:
        id: 2
        name: Product two
    YAML
    with_temp_db(temp_db_data) do |file|
      Product.database_filepath = file.path
      products = Product.where(name: "Product one")
      assert_equal 1, products.size
      assert_equal "Product one", products.first.name
    end
  end

  test "#save stores the product to the YAML file" do
    product = Product.new(id: 1, name: "Product A")
    assert product.save
    loaded_product = Product.find(1)
    assert_equal "Product A", loaded_product.name
  end

  test "#persisted? returns true if the product has an ID" do
    product = Product.new(id: 1)
    assert product.persisted?
  end

  test "#persisted? returns false if the product has no ID" do
    product = Product.new
    refute product.persisted?
  end

  test "#price returns a Money object with the correct amount and currency" do
    product = Product.new(price_amount: 19.99, price_currency: "USD")
    assert_equal Money.from_amount(19.99, "USD"), product.price
  end

  test "#tax returns a Money object with the correct amount and currency" do
    product = Product.new(tax_amount: 1.99, tax_currency: "USD")
    assert_equal Money.from_amount(1.99, "USD"), product.tax
  end

  test "#set_attributes sets the attributes correctly" do
    product = Product.new
    product.set_attributes(id: 1, name: "Product A", price_amount: 9.99)
    assert_equal 1, product.id
    assert_equal "Product A", product.name
    assert_equal 9.99, product.price_amount
  end

  test "#initialize sets attributes on creation" do
    product = Product.new(id: 1, name: "Product A")
    assert_equal 1, product.id
    assert_equal "Product A", product.name
  end

  test ".storage_key_for_product generates a valid key for a persisted product" do
    product = Product.new(id: 10)
    assert_equal "10-product", Product.send(:storage_key_for_product, product)
  end

  test ".safe_storage_attributes converts non-safe types correctly" do
    attributes = {
      id: 1,
      name: "Test",
      price_amount: BigDecimal("19.99"),
      custom: Time.now
    }
    result = Product.send(:safe_storage_attributes, attributes)
    assert_equal 1, result[:id]
    assert_equal "Test", result[:name]
    assert_equal 19.99, result[:price_amount]
    assert_kind_of String, result[:custom]
  end

  test ".save assigns a new ID for unpersisted products" do
    with_temp_db do |file|
      Product.database_filepath = file.path
      product = Product.new(name: "Product B")
      refute product.persisted?
      Product.save(product)
      assert product.persisted?
      assert_equal 1, product.id
      loaded_product = Product.find(1)
      assert_equal "Product B", loaded_product.name
    end
  end

  test ".max returns nil for empty dataset" do
    with_temp_db do |file|
      Product.database_filepath = file.path
      assert_nil Product.max(:price_amount)
    end
  end

  test ".max ignores records with nil attributes" do
    with_temp_db do |file|
      Product.database_filepath = file.path
      Product.new(id: 1, price_amount: nil).save
      Product.new(id: 2, price_amount: 10.0).save
      assert_equal 10.0, Product.max(:price_amount)
    end
  end

  test ".find returns nil when ID is not found" do
    with_temp_db do |file|
      Product.database_filepath = file.path
      assert_nil Product.find(999)
    end
  end

  test ".where handles multiple filter conditions" do
    temp_db_data = <<~YAML
      1-product:
        id: 1
        name: Product one
        price_currency: USD
      2-product:
        id: 2
        name: Product two
        price_currency: USD
      3-product:
        id: 3
        name: Product one
        price_currency: EUR
    YAML
    with_temp_db(temp_db_data) do |file|
      Product.database_filepath = file.path
      products = Product.where(name: "Product one", price_currency: "USD")
      assert_equal 1, products.size
      assert_equal 1, products.first.id
    end
  end

  test ".where returns empty array when no matches found" do
    with_temp_db do |file|
      Product.database_filepath = file.path
      products = Product.where(name: "Nonexistent")
      assert_empty products
    end
  end

  test "attribute defaults are set correctly" do
    product = Product.new
    assert_nil product.id
    assert_equal "", product.sku
    assert_equal "", product.name
    assert_equal "", product.description
    assert_equal "USD", product.price_currency
    assert_equal "USD", product.tax_currency
    assert_equal 0, product.stock
    assert_equal 0.0, product.price_amount
    assert_equal 0.0, product.tax_amount
  end

  test "price_amount and tax_amount respect BigDecimal precision and scale" do
    product = Product.new(price_amount: BigDecimal("123.456"), tax_amount: BigDecimal("78.901"))
    product.save
    loaded_product = Product.find(product.id)
    assert_equal BigDecimal("123.46"), loaded_product.price_amount
    assert_equal BigDecimal("78.90"), loaded_product.tax_amount
  end

  test "#price handles nil amount" do
    product = Product.new(price_amount: nil, price_currency: "USD")
    assert_equal Money.from_amount(0.0, "USD"), product.price
  end

  test ".all handles corrupted YAML file" do
    with_temp_db("invalid: : : yaml") do |file|
      Product.database_filepath = file.path
      assert_raises(Psych::SyntaxError) do
        Product.all
      end
    end
  end

  private

  def with_temp_db(content = nil, &block)
    Tempfile.open do |tempfile|
      tempfile.write(content.to_s)
      tempfile.rewind
      block.call(tempfile)
    end
  end
end
