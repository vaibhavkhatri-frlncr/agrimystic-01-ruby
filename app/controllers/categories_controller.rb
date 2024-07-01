class CategoriesController < ApplicationController
  before_action :validate_json_web_token
  before_action :check_account_activated

  def index
    categories = Category.all
    render json: CategorySerializer.new(categories), status: :ok
  end
end
