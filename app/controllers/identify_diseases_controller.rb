class IdentifyDiseasesController < ApplicationController
  before_action :validate_json_web_token
  before_action :load_identify_disease, only: [:show]

  def index
    identify_diseases = IdentifyDisease.all
    render json: IdentifyDiseaseSerializer.new(identify_diseases), status: :ok
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
