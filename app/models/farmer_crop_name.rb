class FarmerCropName < ApplicationRecord
  has_many :farmer_crop_type_names, dependent: :destroy
  has_many :farmer_crops, dependent: :destroy

  has_one_attached :crop_image

  accepts_nested_attributes_for :farmer_crop_type_names, allow_destroy: true

  before_validation :titleize_name
  before_update :check_types_before_update

  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validate :validate_farmer_crop_name
  validate :crop_image_presence
  validate :crop_image_format
  validate :must_have_at_least_one_type

  private

  def crop_image_presence
    errors.add(:crop_image, 'must be attached') unless crop_image.attached?
  end

  def crop_image_format
    return unless crop_image.attached?

    allowed_types = %w[image/png image/jpg image/jpeg]
    unless crop_image.content_type.in?(allowed_types)
      errors.add(:crop_image, 'must be a valid image format (PNG, JPG, JPEG)')
    end
  end

  def must_have_at_least_one_type
    errors.add(:base, 'Farmer crop name must have at least one type.') if farmer_crop_type_names.empty?
  end

  def check_types_before_update
    types_to_destroy = farmer_crop_type_names.count(&:marked_for_destruction?)

    if types_to_destroy > 0 && farmer_crop_type_names.reject(&:marked_for_destruction?).empty?
      errors.add(:base, 'Farmer crop name must have at least one type.')
      throw(:abort)
    end
  end

  def titleize_name
    self.name = name.to_s.titleize if name.present?
  end

  def validate_farmer_crop_name
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
