class ProductsController < ApplicationController
  before_action :validate_json_web_token
  before_action :check_account_activated
  before_action :load_category, only: [:index]
  before_action :load_product, only: [:show]

  def index
    page     = params[:page] || 1
    per_page = params[:per_page] || 10

    products = @category.present? ? @category.products : Product.all
    products = products.order(created_at: :desc).page(page).per(per_page)

    if products.present?
      render json: {
        products: ProductSerializer.new(products),
        meta: {
          current_page: products.current_page,
          next_page: products.next_page,
          prev_page: products.prev_page,
          total_pages: products.total_pages,
          total_count: products.total_count
        }
      }, status: :ok
    else
      error_message =
        if params[:category_id].present?
          "Products for category id #{params[:category_id]} doesn't exist."
        else
          "No products found."
        end

      render json: {
        errors: [{ message: error_message }]
      }, status: :not_found
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
