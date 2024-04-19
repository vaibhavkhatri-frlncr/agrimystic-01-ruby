class Product < ApplicationRecord
  self.table_name = :products

  belongs_to :category
  has_many :product_variants, dependent: :destroy

  has_one_attached :display_picture

  accepts_nested_attributes_for :product_variants, allow_destroy: true

  validates :name, :description, presence: true
  validates :code, uniqueness: true, presence: true
  validate :must_have_at_least_one_product_variant
  validates_presence_of :display_picture, :message => 'display picture must be attached'
  
  before_update :check_product_variants_before_update
  after_save :calculate_product_total_price

  private

  def must_have_at_least_one_product_variant
    errors.add(:base, 'Product must have at least one product variant') if product_variants.empty?
  end

  def calculate_product_total_price
    total = product_variants.sum(:total_price)
    update_column(:total_price, total)
  end

  def check_product_variants_before_update
    variants_to_destroy = product_variants.count { |v| v.marked_for_destruction? }

    if variants_to_destroy > 0 && product_variants.reject(&:marked_for_destruction?).empty?
      errors.add(:base, 'Product must have at least one product variant.')
      throw(:abort)
    end
  end
end
