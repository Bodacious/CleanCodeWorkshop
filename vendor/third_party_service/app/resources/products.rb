# frozen_string_literal: true

module Resources
  class Products < Sinatra::Base
    register Sinatra::Namespace
    helpers Sinatra::JSON

    before do
      content_type :json
    end

    namespace '/products' do
      get '' do
        json Product.all
      end

      get '/:id' do
        product = Product.find_by(id: params[:id])
        halt 404, json({ error: 'Product not found' }) unless product
        json product
      end

      post '' do
        product = Product.new(JSON.parse(request.body.read))
        if product.save
          status 201
          json product
        else
          halt 422, json(product.errors)
        end
      end

      patch '/:id' do
        product = Product.find_by(id: params[:id])
        halt 404, json({ error: 'Product not found' }) unless product
        if product.update(JSON.parse(request.body.read))
          json product
        else
          halt 422, json(product.errors)
        end
      end

      delete '/:id' do
        product = Product.find_by(id: params[:id])
        halt 404, json({ error: 'Product not found' }) unless product
        product.destroy
        status 204
      end
    end
  end
end