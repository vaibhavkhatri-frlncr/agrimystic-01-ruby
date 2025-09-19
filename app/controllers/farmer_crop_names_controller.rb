class FarmerCropNamesController < ApplicationController
  before_action :validate_json_web_token
  before_action :check_account_activated

  def index
    farmer_crop_names = FarmerCropName.includes(:farmer_crop_type_names).order(:created_at)

    if farmer_crop_names.present?
      render json: FarmerCropNameSerializer.new(farmer_crop_names), status: :ok
    else
      render json: { errors: [{ message: 'No farmer crop names found.' }] }, status: :not_found
    end
  end
end
