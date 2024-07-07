class Cart < ApplicationRecord
  self.table_name = :carts

  belongs_to :account
  has_many :cart_products, dependent: :destroy
  has_many :product_variants, through: :cart_products
  has_many :products, through: :product_variants
end
