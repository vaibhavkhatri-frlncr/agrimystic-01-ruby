class Crop < ApplicationRecord
  has_one :crop_schedule, dependent: :destroy
  has_many :crop_diseases, dependent: :destroy

  has_one_attached :crop_image

  before_validation :titleize_name

  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validate :validate_crop_name
  validate :crop_image_presence
  validate :crop_image_format

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

  def titleize_name
    self.name = name.to_s.titleize if name.present?
  end

  def validate_crop_name
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
