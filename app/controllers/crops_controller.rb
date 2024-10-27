class CropsController < ApplicationController
  before_action :validate_json_web_token
  before_action :load_crop, only: [:show]

  def index
    crops = Crop.all
    render json: CropSerializer.new(crops), status: :ok
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
