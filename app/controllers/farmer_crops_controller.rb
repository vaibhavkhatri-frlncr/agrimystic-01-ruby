class FarmerCropsController < ApplicationController
  before_action :validate_json_web_token
  before_action :check_account_activated
  before_action :ensure_valid_farmer_user, only: [:create, :update, :destroy, :owned]
  before_action :load_farmer_crop_name, only: [:index]
  before_action :load_farmer_crop_for_show, only: [:show]
  before_action :load_farmer_crop, only: [:update, :destroy]

  def index
    page     = params[:page] || 1
    per_page = params[:per_page] || 10

    farmer_crops = FarmerCrop.includes(:farmer_crop_name, :farmer_crop_type_name, :farmer).where(farmer_crop_name_id: @farmer_crop_name.id).order(created_at: :desc).page(page).per(per_page)

    if farmer_crops.present?
      render json: {
        farmer_crops: FarmerCropSerializer.new(farmer_crops),
        meta: {
          current_page: farmer_crops.current_page,
          next_page: farmer_crops.next_page,
          prev_page: farmer_crops.prev_page,
          total_pages: farmer_crops.total_pages,
          total_count: farmer_crops.total_count
        }
      }, status: :ok
    else
      render json: { errors: [{ message: "Farmer crops for farmer crop name id #{params[:farmer_crop_name_id]} doesn't exist." }] }, status: :not_found
    end
  end

  def show
    return if @farmer_crop.nil?

    render json: FarmerCropSerializer.new(@farmer_crop), status: :ok
  end

  def create
    farmer_crop = current_user.farmer_crops.build(farmer_crop_params)

    if farmer_crop.save
      render json: { message: "Farmer crop created successfully."}, status: :created
    else
      render json: { errors: format_activerecord_errors(farmer_crop.errors) }, status: :unprocessable_entity
    end
  end

   def update
    if @farmer_crop.update(farmer_crop_params)
      render json: { message: "Farmer crop updated successfully."}, status: :ok
    else
      render json: { errors: format_activerecord_errors(@farmer_crop.errors) }, status: :unprocessable_entity
    end
  end

  def destroy
    if @farmer_crop.destroy
      render json: { message: "Farmer crop deleted successfully." }, status: :ok
    else
      render json: { errors: format_activerecord_errors(@farmer_crop.errors) }, status: :unprocessable_entity
    end
  end

  def owned
    farmer_crops = current_user.farmer_crops.includes(:farmer_crop_name, :farmer_crop_type_name)

    if farmer_crops.present?
      render json: FarmerCropSerializer.new(farmer_crops), status: :ok
    else
      render json: { errors: [{ message: 'You have not posted any crops yet.' }] }, status: :not_found
    end
  end

  private

  def ensure_valid_farmer_user
    if current_user.is_a?(Trader)
      render json: { errors: [{ message: "Only farmers are allowed to perform this action." }] }, status: :forbidden
    elsif current_user.is_a?(Farmer) && defined?(@farmer_crop) && @farmer_crop.farmer_id != current_user.id
      render json: { errors: [{ message: "You are not authorized as a valid farmer to perform this action." }] }, status: :forbidden
    end
  end

  def load_farmer_crop_name
    @farmer_crop_name = FarmerCropName.find_by(id: params[:farmer_crop_name_id])

    if @farmer_crop_name.nil?
      render json: { errors: [{ message: "Farmer crop name with id #{params[:farmer_crop_name_id]} doesn't exist." }] }, status: :not_found
    end    
  end

  def load_farmer_crop_for_show
    @farmer_crop = FarmerCrop.find_by(id: params[:id])

    if @farmer_crop.nil?
      render json: { errors: [{ message: "Farmer crop with id #{params[:id]} doesn't exist." }] }, status: :not_found
    end
  end

  def load_farmer_crop
    @farmer_crop = current_user.farmer_crops.find_by(id: params[:id])

    if @farmer_crop.nil?
      render json: { errors: [{ message: "No farmer crop found with id #{params[:id]} for the current user." }] }, status: :not_found
    end
  end

  def farmer_crop_params
    params.require(:farmer_crop).permit(
      :farmer_crop_name_id,
      :farmer_crop_type_name_id,
      :variety,
      :description,
      :moisture_content,
      :quantity,
      :price,
      :contact_number,
      farmer_crop_images: []
    )
  end

  def apply_filters(scope)
    if params[:search].present?
      search_term = "%#{params[:search]}%"
      scope = scope.joins(:farmer_crop_name, :farmer_crop_type_name)
                  .where(
                    "farmer_crop_names.name ILIKE :term OR farmer_crop_type_names.name ILIKE :term",
                    term: search_term
                  )
    end

    scope
  end

  def format_activerecord_errors(errors)
    errors.messages.map { |attribute, error| { attribute => error } }
  end
end
