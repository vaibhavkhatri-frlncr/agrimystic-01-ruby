class CropDiseasesController < ApplicationController
  before_action :validate_json_web_token
  before_action :check_account_activated
  before_action :load_crop, only: [:index]
  before_action :load_crop_disease, only: [:show]

  def index
    crop_diseases = @crop.crop_diseases

    if crop_diseases.present?
      render json: CropDiseaseSerializer.new(crop_diseases), status: :ok
    else
      render json: { errors: [{ message: "Crop diseases for crop id #{params[:crop_id]} doesn't exist." }] }, status: :not_found
    end
  end

  def show
    return if @crop_disease.nil?

    render json: CropDiseaseSerializer.new(@crop_disease), status: :ok
  end

  private

  def load_crop
    @crop = Crop.find_by(id: params[:crop_id])

    if @crop.nil?
      render json: { errors: [{ message: "Crop with id #{params[:crop_id]} doesn't exist." }] }, status: :not_found
    end    
  end

  def load_crop_disease
    @crop_disease = CropDisease.find_by(id: params[:id])

    if @crop_disease.nil?
      render json: { errors: [{ message: "Crop disease with id #{params[:id]} doesn't exist." }] }, status: :not_found
    end
  end
end
