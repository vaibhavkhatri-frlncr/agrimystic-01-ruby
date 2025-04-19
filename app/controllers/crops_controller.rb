class CropsController < ApplicationController
  before_action :validate_json_web_token
  before_action :check_account_activated
  before_action :load_crop, only: [:show]

  def index
    crops = Crop.all

    if crops.any?
      render json: CropSerializer.new(crops), status: :ok
    else
      render json: { errors: { message: 'No crops found.' } }, status: :not_found
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
      render json: { errors: [{ message: "Crop with id #{params[:id]} doesn\'t exists." }] }, status: :not_found
    end
  end
end
