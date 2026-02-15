class FarmerCropNamesController < ApplicationController
  before_action :validate_json_web_token
  before_action :check_account_activated
  before_action :load_farmer_crop_name, only: [:show]

  def index
    page     = params[:page] || 1
    per_page = params[:per_page] || 10

    farmer_crop_names = FarmerCropName.includes(:farmer_crop_type_names).order(created_at: :desc).page(page).per(per_page)

    if farmer_crop_names.present?
      render json: {
        farmer_crop_names: FarmerCropNameSerializer.new(farmer_crop_names),
        meta: {
          current_page: farmer_crop_names.current_page,
          next_page: farmer_crop_names.next_page,
          prev_page: farmer_crop_names.prev_page,
          total_pages: farmer_crop_names.total_pages,
          total_count: farmer_crop_names.total_count
        }
      }, status: :ok
    else
      render json: {
        errors: [{ message: 'No farmer crop names found.' }]
      }, status: :not_found
    end
  end

  def show
    return if @farmer_crop_name.nil?

    render json: FarmerCropNameSerializer.new(@farmer_crop_name), status: :ok
  end

  private

  def load_farmer_crop_name
    @farmer_crop_name = FarmerCropName.find_by(id: params[:id])

    if @farmer_crop_name.nil?
      render json: { errors: [{ message: "Farmer crop name with id #{params[:id]} doesn't exist." }] }, status: :not_found
    end
  end
end
