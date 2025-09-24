class ProductVariant < ApplicationRecord
  belongs_to :product
  has_many :cart_product

  validates :size, :price, :quantity, presence: true
  validate :validate_quantity_greater_than_zero
  validate :validate_price_greater_than_zero

  before_validation :normalize_size
  before_save :calculate_variant_total_price

  private

  def normalize_size
    return if size.blank?

    match = size.strip.match(/\A(\d+(?:\.\d+)?)(\s*[a-zA-Z]+)\z/)

    if match
      number = match[1]
      unit = match[2].strip.downcase
      self.size = "#{number} #{unit}"
    else
      self.size = size.strip.downcase
    end
  end

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
