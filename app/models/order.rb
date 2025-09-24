class Order < ApplicationRecord
  belongs_to :farmer, class_name: "Farmer"
  belongs_to :address
  has_many :order_products, dependent: :destroy

  validates :payment_method, presence: true, inclusion: { in: ['online', 'cod'] }
  validates :order_status, presence: true, inclusion: { in: ['placed', 'processing', 'shipped', 'delivered', 'cancelled'] }
  validates :payment_status, inclusion: { in: ['pending', 'completed', 'failed', nil] }
  validates :total_amount, presence: true, numericality: { greater_than: 0 }

  scope :pending_payment, -> { where(payment_status: 'pending') }
  scope :completed_payment, -> { where(payment_status: 'completed') }
  scope :cancelled, -> { where(order_status: 'cancelled') }
  scope :recent, -> { order(created_at: :desc) }

  def completed?
    payment_status == 'completed'
  end

  def cancelled?
    order_status == 'cancelled'
  end

  def cancelable?
    order_status == 'placed'
  end

  def product_count
    order_products.sum(:quantity)
  end

  def payment_due?
    payment_method == 'online' && payment_status != 'completed'
  end
end
