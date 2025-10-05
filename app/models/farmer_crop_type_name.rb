class FarmerCropTypeName < ApplicationRecord
  belongs_to :farmer_crop_name
  has_many :farmer_crops, dependent: :destroy

  validates :name, presence: true, uniqueness: { scope: :farmer_crop_name_id, case_sensitive: false }
  validate :validate_farmer_crop_type_name

  private

  def validate_farmer_crop_type_name
    value = name.to_s.strip

    return if value.blank?

    if value.length < 2
      errors.add(:name, "is too short (minimum is 2 characters)")
      return
    end

    if value.length > 50
      errors.add(:name, "is too long (maximum is 50 characters)")
      return
    end

    unless value.match?(/\A[a-zA-Z\s]+\z/)
      errors.add(:name, 'only allows letters and spaces')
    end
  end
end
