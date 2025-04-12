class CropDisease < ApplicationRecord
  self.table_name = :crop_diseases

  belongs_to :crop
  has_one_attached :disease_image

  validates :disease_name, :disease_cause, :solution, :products_recommended, presence: true
  validate :disease_image_presence
  validate :disease_image_format
  validate :unique_disease_name_for_crop

  before_validation :format_fields

  private

  def format_fields
    self.disease_name = titleize_string(disease_name)
    self.products_recommended = titleize_string(products_recommended)
    self.disease_cause = capitalize_string(disease_cause)
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

    allowed_types = %w[
      image/png
      image/jpg
      image/jpeg
      image/gif
      image/bmp
      image/webp
      image/tiff
      image/x-icon
      image/vnd.microsoft.icon
      image/heif
      image/heic
      image/svg+xml
    ]

    unless disease_image.content_type.in?(allowed_types)
      errors.add(:disease_image, 'must be a valid image format (PNG, JPG, JPEG, GIF, BMP, WEBP, TIFF, ICO, HEIF, HEIC, SVG)')
    end
  end

  def unique_disease_name_for_crop
    if CropDisease.where(crop_id: crop_id)
                  .where('LOWER(disease_name) = ?', disease_name.downcase)
                  .where.not(id: id)
                  .exists?
      errors.add(:disease_name, 'this crop already has a disease entry with the same name')
    end
  end
end
