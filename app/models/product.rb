class Product < ApplicationRecord
  belongs_to :category
  has_many :product_variants, dependent: :destroy

  has_many_attached :images
  has_one_attached :product_image

  accepts_nested_attributes_for :product_variants, allow_destroy: true

  before_validation :format_fields
  before_update :check_product_variants_before_update
  after_save :calculate_product_total_price
  
  validates :name, :description, :manufacturer, :dosage, :features, presence: true
  validate :validate_product_name
  validates :code, uniqueness: true, presence: true
  validate :must_have_at_least_one_product_variant
  validate :product_image_presence
  validate :product_image_format
  validate :images_format

  private

  def format_fields
    self.name = titleize_string(name)
    self.manufacturer = titleize_string(manufacturer)
    self.features = titleize_string(features)

    self.dosage = capitalize_string(dosage)
    self.description = capitalize_string(description)
  end

  def titleize_string(str)
    str.to_s.titleize if str.present?
  end

  def capitalize_string(str)
    str.to_s.capitalize if str.present?
  end

  def product_image_presence
    errors.add(:product_image, 'must be attached') unless product_image.attached?
  end

  def product_image_format
    return unless product_image.attached?

    allowed_types = %w[image/png image/jpg image/jpeg]
    unless product_image.content_type.in?(allowed_types)
      errors.add(:product_image, 'must be a valid image format (PNG, JPG, JPEG)')
    end
  end

  def images_format
    return unless images.attached?

    allowed_types = %w[image/png image/jpg image/jpeg]

    images.each do |image|
      unless image.content_type.in?(allowed_types)
        errors.add(:images, 'must be a valid image format (PNG, JPG, JPEG)')
      end
    end
  end

  def must_have_at_least_one_product_variant
    errors.add(:base, 'Product must have at least one product variant.') if product_variants.empty?
  end

  def calculate_product_total_price
    total = product_variants.sum(:total_price)
    update_column(:total_price, total)
  end

  def check_product_variants_before_update
    variants_to_destroy = product_variants.count(&:marked_for_destruction?)

    if variants_to_destroy > 0 && product_variants.reject(&:marked_for_destruction?).empty?
      errors.add(:base, 'Product must have at least one product variant.')
      throw(:abort)
    end
  end

  def validate_product_name
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
