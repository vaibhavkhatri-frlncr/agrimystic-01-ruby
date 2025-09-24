class Farmer < Account
  has_one :cart, dependent: :destroy
	has_many :cart_products, through: :cart
	has_many :products, through: :cart_products
	has_many :addresses, dependent: :destroy
	has_many :orders, dependent: :destroy
	has_many :order_products, through: :order
  has_many :farmer_crops, dependent: :destroy
end
