class EnquiriesController < ApplicationController
  before_action :validate_json_web_token
  before_action :check_account_activated
  before_action :set_farmer_crop, only: [:create]
  before_action :load_enquiry, only: [:destroy]
  before_action :ensure_valid_trader_account, only: [:create]
  before_action :ensure_valid_farmer_account, only: [:index, :destroy]

  def index
    page = params[:page] || 1
    per_page = params[:per_page] || 10

    enquiries = Enquiry.joins(:farmer_crop).where(farmer_crops: { farmer_id: current_user.id }).order(created_at: :desc).page(page).per(per_page)

    if enquiries.present?
      render json: {
        enquiries: EnquirySerializer.new(enquiries),
        meta: {
          current_page: enquiries.current_page,
          next_page: enquiries.next_page,
          prev_page: enquiries.prev_page,
          total_pages: enquiries.total_pages,
          total_count: enquiries.total_count
        }
      }, status: :ok
    else
      render json: {
        errors: [{ message: 'No enquiries found.' }]
      }, status: :not_found
    end
  end

  def create
    enquiry = @farmer_crop.enquiries.build(
      enquiry_params.merge(trader_id: current_user.id)
    )

    if enquiry.save
      render json: { message: 'Enquiry created successfully.' }, status: :created
    else
      render json: { errors: format_activerecord_errors(enquiry.errors) }, status: :unprocessable_entity
    end
  end

  def destroy
    unless @enquiry.farmer_crop.farmer_id == current_user.id
      return render json: { errors: [{ message: 'You are not authorized as a valid farmer to perform this action.' }] }, status: :forbidden
    end

    if @enquiry.destroy
      render json: { message: 'Enquiry deleted successfully.' }, status: :ok
    else
      render json: { errors: format_activerecord_errors(@enquiry.errors) }, status: :unprocessable_entity
    end
  end

  private

  def ensure_valid_trader_account
    if current_user.is_a?(Farmer)
      render json: { errors: [{ message: 'Only traders are allowed to perform this action.' }] }, status: :forbidden
    end
  end

  def ensure_valid_farmer_account
    unless current_user.is_a?(Farmer)
      render json: { errors: [{ message: 'Only farmers are allowed to perform this action.' }] }, status: :forbidden
    end
  end

  def set_farmer_crop
    @farmer_crop = FarmerCrop.find_by(id: params[:farmer_crop_id])

    if @farmer_crop.nil?
      render json: {
        errors: [{ message: "Farmer crop with id #{params[:farmer_crop_id]} doesn't exist." }]
      }, status: :not_found
    end
  end

  def load_enquiry
    @enquiry = Enquiry.find_by(id: params[:id])

    if @enquiry.nil?
      render json: {
        errors: [{ message: "Enquiry with id #{params[:id]} doesn't exist." }]
      }, status: :not_found
    end
  end

  def enquiry_params
    params.require(:enquiry).permit(:message)
  end

  def format_activerecord_errors(errors)
    errors.messages.map { |attribute, error| { attribute => error } }
  end
end
