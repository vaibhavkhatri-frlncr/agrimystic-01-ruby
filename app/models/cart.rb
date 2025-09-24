class Cart < ApplicationRecord
  belongs_to :farmer, class_name: "Farmer"
  has_many :cart_products, dependent: :destroy
  has_many :product_variants, through: :cart_products
  has_many :products, through: :product_variants
end
