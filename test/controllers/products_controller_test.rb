require "test_helper"

class ProductsControllerTest < ActionDispatch::IntegrationTest
  include FactoryBot::Syntax::Methods

  setup :create_test_yaml_store
  teardown :destroy_test_yaml_store

  test "#index returns 200 success" do
    get products_url, as: :json

    assert_response :success
  end

  test "#index loads all products" do
    Product.expects(:all).returns([]).at_least_once

    get products_url, as: :json

    assert_response :success
  end

  test "#index renders all products as json" do
    products = build_list :product, 3
    products.each { |prod| prod.expects(:as_json).returns(prod.attributes) }
    Product.stubs(:all).returns(products)

    get products_url, as: :json
  end

  test "#create should create product" do
    assert_difference("Product.count") do
      Product.any_instance.expects(:valid?).returns(true)
      post products_url, params: { product: attributes_for(:product) }, as: :json
    end

    assert_response :created
  end

  test "#create should respond bad request if input missing" do
    post products_url, params: {}, as: :json

    assert_response :bad_request
  end

  test "#create should respond unprocessable entity if input invalid" do
    Product.any_instance.expects(:save).returns(false)

    post products_url, params: { description: "new-description" }, as: :json

    assert_response :unprocessable_entity
  end

  test "#create renders new product as json" do
    product = build :product
    Product.any_instance.expects(:as_json).returns(product.attributes)

    post products_url, params: { product: product.attributes }, as: :json
  end

  test "#show returns a 200 success" do
    product = build_stubbed(:product)
    Product.expects(:find).returns(product)

    get product_url(product), as: :json

    assert_response :success
  end

  test "#show fetches the Product from the id param" do
    product = build(:product, id: 0)
    Product.expects(:find).with("0").returns(product)

    get product_url(id: "0"), as: :json

    assert_response :success
  end

  test "#update fetches the Product from the id param" do
    product = build(:product, id: 0)
    Product.expects(:find).with("0").returns(product)

    patch product_url(id: "0"), params: { product: {} }, as: :json
  end

  test "#update updates the Product with params" do
    product = build(:product, id: 0)
    Product.stubs(:find).with("0").returns(product)
    product.expects(:update).with(instance_of(ActionController::Parameters)).returns(true)

    patch product_url(id: "0"), params: { product: { description: "new-description" } }, as: :json
  end

  test "#update responds with 200 when update successful" do
    product = build(:product, id: 0)
    Product.stubs(:find).with("0").returns(product)
    product.stubs(:update).returns(true)

    patch product_url(id: "0"), params: { product: { description: "new-description" } }, as: :json

    assert_response :success
  end

  test "#update responds with 422 when update not successful" do
    product = build(:product, id: 0)
    Product.stubs(:find).with("0").returns(product)
    product.stubs(:update).returns(false)

    patch product_url(id: "0"), params: { product: { description: "new-description" } }, as: :json

    assert_response :unprocessable_entity
  end

  test "#update should respond bad request if input missing" do
    product = build(:product, id: 0)
    Product.stubs(:find).with("0").returns(product)

    patch product_url(id: "0"), params: {}, as: :json

    assert_response :bad_request
  end

  test "#destroy destroys the Product record" do
    product = build(:product, id: 0)
    Product.stubs(:find).with("0").returns(product)
    product.expects(:destroy!)

    delete product_url(id: "0"), as: :json
  end

  test "#destroy responds with 204" do
    product = build(:product, id: 0)
    Product.stubs(:find).with("0").returns(product)

    delete product_url(id: "0"), as: :json

    assert_response 204
  end
end
