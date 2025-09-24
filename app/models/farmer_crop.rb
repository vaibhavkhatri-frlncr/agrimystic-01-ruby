class FarmerCrop < ApplicationRecord
  belongs_to :farmer, class_name: "Farmer"
  belongs_to :farmer_crop_name
  belongs_to :farmer_crop_type_name

  has_many_attached :farmer_crop_images

  validates :farmer_crop_name_id, :farmer_crop_type_name_id, :quantity, :price, :contact_number, presence: true
  validates :farmer_crop_type_name_id, uniqueness: { scope: [:farmer_id, :farmer_crop_name_id], message: "you have already added this crop and type combination" }
  validates :contact_number, numericality: { only_integer: true }, length: { is: 10 }
  validate :farmer_crop_images_presence
  validate :farmer_crop_images_format

  private

  def farmer_crop_images_presence
    errors.add(:farmer_crop_images, 'must be attached') unless farmer_crop_images.attached?
  end

  def farmer_crop_images_format
    return unless farmer_crop_images.attached?

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

    farmer_crop_images.each do |image|
      unless image.content_type.in?(allowed_types)
        errors.add(:farmer_crop_images, 'must be a valid image format (PNG, JPG, JPEG, GIF, BMP, WEBP, TIFF, ICO, HEIF, HEIC, SVG)')
      end
    end
  end
end
