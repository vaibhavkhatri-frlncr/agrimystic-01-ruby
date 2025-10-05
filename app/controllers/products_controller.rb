class ProductsController < ApplicationController
  before_action :validate_json_web_token
  before_action :check_account_activated
  before_action :load_category, only: [:index]
  before_action :load_product, only: [:show]

  def index
    products = @category.present? ? @category.products : Product.all
    products = products.order(created_at: :desc)

    if products.any?
      render json: { products: ProductSerializer.new(products) }, status: :ok
    else
      render json: { errors: [{ message: 'No products found.' }] }, status: :not_found
    end
  end

  def show
    return if @product.nil?

    render json: ProductSerializer.new(@product), status: :ok
  end

  private

  def load_category
    if params[:category_id].present?
      @category = Category.find_by(id: params[:category_id])
      if @category.nil?
        render json: { errors: [{ message: "Category with id #{params[:category_id]} doesn't exist." }] }, status: :not_found
      end
    end
  end

  def load_product
    @product = Product.find_by(id: params[:id])

    if @product.nil?
      render json: { errors: [{ message: "Product with id #{params[:id]} doesn't exist." }] }, status: :not_found
    end
  end
end
