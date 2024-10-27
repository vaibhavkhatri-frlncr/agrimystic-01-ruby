class ProductVariant < ApplicationRecord
  self.table_name = :product_variants

  belongs_to :product
  has_many :cart_product

  validates :size, :price, :quantity, presence: true
  validate :validate_quantity_greater_than_zero
  validate :validate_price_greater_than_zero

  before_save :calculate_variant_total_price

  private

  def validate_quantity_greater_than_zero
    if quantity.blank? || !quantity.is_a?(Integer) || quantity <= 0
      errors.add(:quantity, 'must be greater than 0')
    end
  end

  def validate_price_greater_than_zero
    if price.blank? || price <= 0
      errors.add(:price, 'must be greater than 0')
    end
  end

  def calculate_variant_total_price
    self.total_price = quantity * price
  end
end
