class ReviewsController < ApplicationController
  before_action :validate_json_web_token
  before_action :check_account_activated
  before_action :load_review, only: [:destroy]
  before_action :set_farmer_crop, only: [:index, :create]
  before_action :ensure_valid_trader_account, only: [:create, :destroy]

  def index
    reviews = @farmer_crop.reviews.order(created_at: :desc)
  
    if reviews.present?
      render json: ReviewSerializer.new(reviews, { params: { current_user_id: current_user.id } }), status: :ok
    else
      render json: { errors: [{ message: "Reviews for farmer crop id #{params[:farmer_crop_id]} doesn't exist." }] }, status: :not_found
    end
  end

  def create
    existing_review = @farmer_crop.reviews.find_by(trader_id: current_user.id)

    if existing_review
      render json: { errors: [{ message: 'You have already reviewed this crop.' }] }, status: :unprocessable_entity and return
    end

    review = @farmer_crop.reviews.build(review_params.merge(trader_id: current_user.id))

    if review.save
      render json: { message: 'Review created successfully.' }, status: :created
    else
      render json: { errors: format_activerecord_errors(review.errors) }, status: :unprocessable_entity
    end
  end

  def destroy
    if @review.destroy
      render json: { message: 'Review deleted successfully.' }, status: :ok
    else
      render json: { errors: format_activerecord_errors(review.errors) }, status: :unprocessable_entity
    end
  end

  private

  def ensure_valid_trader_account
    if current_user.is_a?(Farmer)
      render json: { errors: [{ message: "Only traders are allowed to perform this action." }] }, status: :forbidden
    elsif current_user.is_a?(Trader) && defined?(@review) && @review.trader_id != current_user.id
      render json: { errors: [{ message: "You are not authorized as a valid trader to perform this action." }] }, status: :forbidden
    end
  end

  def set_farmer_crop
    @farmer_crop = FarmerCrop.find_by(id: params[:farmer_crop_id])

    if @farmer_crop.nil?
      render json: { errors: [{ message: "Farmer crop with id #{params[:farmer_crop_id]} doesn't exist." }] }, status: :not_found
    end
  end

  def load_review
    @review = current_user.reviews.find_by(id: params[:id])
    
    if @review.nil?
      render json: { errors: [{ message: "No review found with id #{params[:id]} for the current user." }] }, status: :not_found
    end
  end

  def review_params
    params.require(:review).permit(
      :rating,
      :review
    )
  end

  def format_activerecord_errors(errors)
    errors.messages.map { |attribute, error| { attribute => error } }
  end
end
