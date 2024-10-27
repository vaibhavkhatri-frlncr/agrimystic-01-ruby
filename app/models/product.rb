class Product < ApplicationRecord
  self.table_name = :products

  belongs_to :category
  has_one_attached :product_image
  has_many :product_variants, dependent: :destroy
  has_many_attached :images

  accepts_nested_attributes_for :product_variants, allow_destroy: true

  validates :name, :description, :manufacturer, :dosage, :features, presence: true
  validates :code, uniqueness: true, presence: true
  validate :must_have_at_least_one_product_variant
  validate :product_image_presence
  validate :product_image_format
  validate :images_format

  before_update :check_product_variants_before_update
  after_save :calculate_product_total_price

  private

  def product_image_presence
    errors.add(:product_image, 'must be attached') unless product_image.attached?
  end

  def product_image_format
    errors.add(:product_image, 'must be a PNG, JPG, or JPEG') if product_image.attached? && !product_image.content_type.in?(%w[image/png image/jpg image/jpeg])
  end

  def images_format
    if images.attached?
      images.each do |image|
        unless image.content_type.in?(%w[image/png image/jpg image/jpeg])
          errors.add(:images, 'must be PNG, JPG, or JPEG')
        end
      end
    end
  end

  def must_have_at_least_one_product_variant
    errors.add(:base, 'Product must have at least one product variant') if product_variants.empty?
  end

  def calculate_product_total_price
    total = product_variants.sum(:total_price)
    update_column(:total_price, total)
  end

  def check_product_variants_before_update
    variants_to_destroy = product_variants.count(&:marked_for_destruction?)

    if variants_to_destroy > 0 && product_variants.reject(&:marked_for_destruction?).empty?
      errors.add(:base, 'Product must have at least one product variant')
      throw(:abort)
    end
  end
end
