class CategoriesController < ApplicationController
  before_action :validate_json_web_token
  before_action :check_account_activated

  def index
    categories = Category.all

    if categories.any?
      render json: CategorySerializer.new(categories), status: :ok
    else
      render json: { errors: { message: 'No categories found' } }, status: :not_found
    end
  end
end
