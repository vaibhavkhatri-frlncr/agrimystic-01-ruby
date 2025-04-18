class Order < ApplicationRecord
  self.table_name = :orders

  belongs_to :account
  belongs_to :address
  has_many :order_products, dependent: :destroy

  # enum order_status: {
  #   placed: 'placed',
  #   confirmed: 'confirmed',
  #   shipped: 'shipped',
  #   delivered: 'delivered',
  #   cancelled: 'cancelled',
  #   returned: 'returned',
  #   failed: 'failed'
  # }

  # enum payment_status: {
  #   pending: 'pending',
  #   paid: 'paid',
  #   failed: 'failed'
  # }
end
