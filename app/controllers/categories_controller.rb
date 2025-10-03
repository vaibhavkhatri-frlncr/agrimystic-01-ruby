class CategoriesController < ApplicationController
  before_action :validate_json_web_token
  before_action :check_account_activated

  def index
    categories = Category.order(created_at: :desc)

    if categories.present?
      render json: CategorySerializer.new(categories), status: :ok
    else
      render json: { errors: [{ message: 'No categories found.' }] }, status: :not_found
    end
  end
end
