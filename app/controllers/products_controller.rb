class ProductsController < ApplicationController
  before_action :validate_json_web_token
  before_action :check_account_activated
  before_action :load_product, only: [:show]

  def index
    products = Product.all
    render json: ProductSerializer.new(products), status: :ok
  end

  def show
    return if @product.nil?
    render json: ProductSerializer.new(@product), status: :ok
  end

  private

  def load_product
    @product = Product.find_by(id: params[:id])

    if @product.nil?
      render json: {
          message: "Product with id #{params[:id]} doesn\'t exists"
      }, status: :not_found
    end
  end
end
