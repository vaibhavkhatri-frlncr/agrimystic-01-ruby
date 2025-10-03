class CropDisease < ApplicationRecord
  belongs_to :crop

  has_one_attached :disease_image

  before_validation :format_fields
  
  validates :name, :cause, :solution, :products_recommended, presence: true
  validate :validate_disease_name
  validate :disease_image_presence
  validate :disease_image_format
  validate :unique_name_for_crop

  private

  def format_fields
    self.name = titleize_string(name)
    self.products_recommended = titleize_string(products_recommended)
    self.cause = capitalize_string(cause)
    self.solution = capitalize_string(solution)
  end

  def titleize_string(str)
		str.to_s.titleize if str.present?
	end

  def capitalize_string(str)
    str.to_s.capitalize if str.present?
  end

  def disease_image_presence
    errors.add(:disease_image, 'must be attached') unless disease_image.attached?
  end

  def disease_image_format
    return unless disease_image.attached?

    allowed_types = %w[image/png image/jpg image/jpeg]
    unless disease_image.content_type.in?(allowed_types)
      errors.add(:disease_image, 'must be a valid image format (PNG, JPG, JPEG)')
    end
  end

  def unique_name_for_crop
    value = name.to_s.strip

    return if value.blank?

    if CropDisease.where(crop_id: crop_id)
                  .where('LOWER(name) = ?', value.downcase)
                  .where.not(id: id)
                  .exists?
      errors.add(:name, 'this crop already has a disease entry with the same name')
    end
  end

  def validate_disease_name
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
