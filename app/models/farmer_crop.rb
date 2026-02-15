class FarmerCrop < ApplicationRecord
  belongs_to :farmer, class_name: 'Farmer'
  belongs_to :farmer_crop_name
  belongs_to :farmer_crop_type_name
  has_many :reviews, dependent: :destroy
  has_many :enquiries, dependent: :destroy

  has_many_attached :farmer_crop_images

  before_validation :format_description

  ransacker :contact_number, formatter: proc { |v| v } do |parent|
    Arel.sql("CAST(#{parent.table[:contact_number].name} AS TEXT)")
  end

  validates :farmer_crop_type_name_id, uniqueness: { scope: [:farmer_id, :farmer_crop_name_id], message: "you have already added this crop and type combination" }
  validates :quantity, :price, presence: true
  validate :validate_contact_number
  validate :validate_description
  validate :validate_farmer_crop_images

  private

  def format_description
    self.description = capitalize_string(description)
  end

  def capitalize_string(str)
    str.to_s.capitalize if str.present?
  end

  def validate_contact_number
    if contact_number.blank?
      errors.add(:contact_number, "can't be blank")
      return
    end

    unless contact_number.to_s.match?(/\A[7-9]\d{9}\z/)
      errors.add(:contact_number, "must be a valid 10-digit Indian contact number starting with 7, 8, or 9")
    end
  end

  def validate_farmer_crop_images
    unless farmer_crop_images.attached?
      errors.add(:farmer_crop_images, 'must be attached')
      return
    end

    allowed_types = %w[image/png image/jpg image/jpeg]
    invalid_image = farmer_crop_images.any? { |image| !image.content_type.in?(allowed_types) }

    if invalid_image
      errors.add(:farmer_crop_images, 'must be a valid image format (PNG, JPG, JPEG)')
    end
  end

  def validate_description
    value = description.to_s.strip

    if value.blank?
      errors.add(:description, "can't be blank")
      return
    end

    if value.length < 5
      errors.add(:description, "is too short (minimum is 5 characters)")
      return
    end

    if value.length > 500
      errors.add(:description, "is too long (maximum is 500 characters)")
      return
    end

    unless value.match?(/\A[a-zA-Z0-9\s.,!@#&()-]*\z/)
      errors.add(:description, "contains invalid characters (only letters, numbers, spaces, and basic punctuation are allowed)")
    end
  end
end
