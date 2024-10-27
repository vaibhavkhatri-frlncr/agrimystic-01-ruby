class IdentifyDiseasesController < ApplicationController
  before_action :validate_json_web_token
  before_action :load_identify_disease, only: [:show]

  def index
    crop = Crop.find_by(id: params[:id])

    if crop.nil?
      render json: { errors: [{ message: "Crop with id #{params[:id]} doesn't exist." }] }, status: :not_found
    else
      identify_diseases = crop.identify_diseases

      if identify_diseases.nil?
        render json: { data: [] }, status: :ok
      else
        render json: IdentifyDiseaseSerializer.new(identify_diseases), status: :ok
      end
    end
  end

  def show
    return if @identify_disease.nil?
    render json: IdentifyDiseaseSerializer.new(@identify_disease), status: :ok
  end

  private

  def load_identify_disease
    @identify_disease = IdentifyDisease.find_by(id: params[:id])

    if @identify_disease.nil?
      render json: { errors: [{ message: "Identify disease with id #{params[:id]} doesn\'t exists." }] }, status: :not_found
    end
  end
end
