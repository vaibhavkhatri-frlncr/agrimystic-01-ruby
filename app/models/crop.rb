class Crop < ApplicationRecord
  has_one :crop_schedule, dependent: :destroy
  has_many :crop_diseases, dependent: :destroy

  has_one_attached :crop_image

  before_validation :titleize_name

  validates :name, presence: true, uniqueness: { case_sensitive: false }, length: { maximum: 50 }
  validate :crop_image_presence
  validate :crop_image_format

  private

  def crop_image_presence
    errors.add(:crop_image, 'must be attached') unless crop_image.attached?
  end

  def crop_image_format
    return unless crop_image.attached?

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

    unless crop_image.content_type.in?(allowed_types)
      errors.add(:crop_image, 'must be a valid image format (PNG, JPG, JPEG, GIF, BMP, WEBP, TIFF, ICO, HEIF, HEIC, SVG)')
    end
  end

  def titleize_name
    self.name = name.to_s.titleize if name.present?
  end
end
