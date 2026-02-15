class ReviewsController < ApplicationController
  before_action :validate_json_web_token
  before_action :check_account_activated
  before_action :load_review, only: [:destroy]
  before_action :set_farmer_crop, only: [:index, :create]
  before_action :ensure_valid_trader_account, only: [:create, :destroy]

  def index
    page = params[:page] || 1
    per_page = params[:per_page] || 10

    reviews = @farmer_crop.reviews.order(created_at: :desc)
    paginated_reviews = reviews.page(page).per(per_page)

    if paginated_reviews.present?
      render json: {
        reviews: ReviewSerializer.new(
          paginated_reviews,
          { params: { current_user_id: current_user.id } }
        ),
        meta: {
          current_page: paginated_reviews.current_page,
          next_page: paginated_reviews.next_page,
          prev_page: paginated_reviews.prev_page,
          total_pages: paginated_reviews.total_pages,
          total_count: paginated_reviews.total_count
        }
      }, status: :ok
    else
      render json: {
        errors: [
          { message: "Reviews for farmer crop id #{params[:farmer_crop_id]} doesn't exist." }
        ]
      }, status: :not_found
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
