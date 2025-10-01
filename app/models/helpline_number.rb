class HelplineNumber < ApplicationRecord
  before_validation :titleize_region

  ransacker :phone_number, formatter: proc { |v| v } do |parent|
    Arel.sql("CAST(#{parent.table[:phone_number].name} AS TEXT)")
  end

  validates :phone_number,
            presence: { message: "can't be blank" },
            uniqueness: { case_sensitive: false, message: "has already been taken" }
  validate :validate_phone_number_format
  validates :region,
            presence: { message: "can't be blank" },
            uniqueness: { case_sensitive: false, message: "has already been taken" }
  validate :validate_region_length

  private

  def titleize_region
    self.region = region.to_s.titleize if region.present?
  end

  def validate_phone_number_format
    return if phone_number.blank?

    unless phone_number.to_s.match?(/\A[7-9]\d{9}\z/)
      errors.add(:phone_number, "must be a valid 10-digit Indian phone number starting with 7, 8, or 9")
    end
  end

  def validate_region_length
    return if region.blank?

    if region.length < 3
      errors.add(:region, "is too short (minimum is 3 characters)")
    elsif region.length > 100
      errors.add(:region, "is too long (maximum is 100 characters)")
    end
  end
end
