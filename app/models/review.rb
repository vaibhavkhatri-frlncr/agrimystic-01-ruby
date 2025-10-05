class Review < ApplicationRecord
  belongs_to :trader, class_name: 'Trader'
  belongs_to :farmer_crop

  before_validation :format_review

  validates :trader_id, uniqueness: { scope: :farmer_crop_id, message: 'has already reviewed this crop' }
  validate :validate_rating
  validate :validate_review

  private

  def format_review
    self.review = capitalize_string(review)
  end

  def capitalize_string(str)
    str.to_s.capitalize if str.present?
  end

  def validate_rating
    if rating.blank?
      errors.add(:rating, "can't be blank")
      return
    end

    unless rating.is_a?(Numeric) && rating.to_i.between?(1, 5)
      errors.add(:rating, "must be between 1 and 5")
    end
  end

  def validate_review
    value = review.to_s.strip

    if value.blank?
      errors.add(:review, "can't be blank")
      return
    end

    if value.length < 5
      errors.add(:review, "is too short (minimum is 5 characters)")
      return
    end

    if value.length > 500
      errors.add(:review, "is too long (maximum is 200 characters)")
      return
    end

    unless value.match?(/\A[a-zA-Z0-9\s.,!@#&()-]*\z/)
      errors.add(:review, "contains invalid characters (only letters, numbers, spaces, and basic punctuation are allowed)")
    end
  end
end
