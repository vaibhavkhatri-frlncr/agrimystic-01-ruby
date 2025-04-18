class OrderProduct < ApplicationRecord
  belongs_to :order
  belongs_to :product_variant

  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :total_price, numericality: { greater_than_or_equal_to: 0 }

  before_validation :calculate_total_price

  private

  def calculate_total_price
    self.total_price = quantity.to_i * price.to_f
  end
end
