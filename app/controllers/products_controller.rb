class ProductsController < ApplicationController
  before_action :validate_json_web_token
  before_action :check_account_activated
  before_action :load_product, only: [:show]

  def index
    products = params[:category_id].present? ? Product.where(category_id: params[:category_id]) : Product.all
    render json: ProductSerializer.new(products), status: :ok
  end

  def show
    return if @product.nil?
    render json: ProductSerializer.new(@product), status: :ok
  end

  def search
    if params[:query].present?
      query = params[:query].strip
      @products = SearchProducts.search_records(query)

      if @products.present?
        render json: ProductSerializer.new(@products), status: :ok
      else
        render json: { errors: [{ message: 'No products found.' }] }, status: :not_found
      end
    else
      render json: { errors: [{ message: 'Search query can\'t be blank.' }] }, status: :unprocessable_entity
    end
  end

  private

  def load_product
    @product = Product.find_by(id: params[:id])

    if @product.nil?
      render json: { errors: [{ message: "Product with id #{params[:id]} doesn\'t exists." }] }, status: :not_found
    end
  end
end
