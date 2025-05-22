class ProductsController < ApplicationController
  rescue_from Product::RecordNotFound, with: :record_not_found
  # GET /products
  def index
    @products = Product.all

    render json: @products
  end

  # GET /products/1
  def show
    @product = Product.find(params[:id])
    render json: @product
  end

  # POST /products
  def create
    @product = Product.new(product_params)
    if @product.save
      render json: @product, status: :created, location: @product
    else
      render json: @product.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /products/1
  def update
    @product = Product.find(params[:id])
    if @product.update(product_params)
      render json: @product
    else
      render json: @product.errors, status: :unprocessable_entity
    end
  end

  # DELETE /products/1
  def destroy
    @product = Product.find(params[:id])
    @product.destroy!

    head :no_content
  end

  protected

  # Use callbacks to share common setup or constraints between actions.

  # Only allow a list of trusted parameters through.
  def product_params
    params.expect(product: [
      :name,
      :sku,
      :description,
      :price_amount,
      :price_currency,
      :tax_amount,
      :tax_currency,
      :stock
    ])
  end

  def record_not_found
    render json: { errors: [ "Record not found" ] }, status: :not_found
  end
end
