class CropsController < ApplicationController
  before_action :validate_json_web_token
  before_action :check_account_activated
  before_action :load_crop, only: [:show]

  def index
    page     = params[:page] || 1
    per_page = params[:per_page] || 10

    crops = Crop.order(created_at: :desc).page(page).per(per_page)

    if crops.any?
      render json: {
        crops: CropSerializer.new(crops),
        meta: {
          current_page: crops.current_page,
          next_page: crops.next_page,
          prev_page: crops.prev_page,
          total_pages: crops.total_pages,
          total_count: crops.total_count
        }
      }, status: :ok
    else
      render json: { errors: [{ message: 'No crops found.' }] }, status: :not_found
    end
  end

  def show
    return if @crop.nil?

    render json: CropSerializer.new(@crop), status: :ok
  end

  private

  def load_crop
    @crop = Crop.find_by(id: params[:id])

    if @crop.nil?
      render json: { errors: [{ message: "Crop with id #{params[:id]} doesn't exist." }] }, status: :not_found
    end
  end
end
