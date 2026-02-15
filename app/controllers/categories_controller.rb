class CategoriesController < ApplicationController
  before_action :validate_json_web_token
  before_action :check_account_activated

  def index
    page     = params[:page] || 1
    per_page = params[:per_page] || 10

    categories = Category.order(created_at: :desc).page(page).per(per_page)

    if categories.present?
      render json: {
        categories: CategorySerializer.new(categories),
        meta: {
          current_page: categories.current_page,
          next_page: categories.next_page,
          prev_page: categories.prev_page,
          total_pages: categories.total_pages,
          total_count: categories.total_count
        }
      }, status: :ok
    else
      render json: {
        errors: [{ message: 'No categories found.' }]
      }, status: :not_found
    end
  end
end
