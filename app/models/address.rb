class Address < ApplicationRecord
  belongs_to :farmer, class_name: "Farmer"
  has_many :orders

  before_validation :titleize_address_fields

  enum address_type: { home: 0, office: 1, other: 2 }

  validates :name, :mobile, :pincode, :state, :address, :district, presence: true
  validates :mobile, numericality: { only_integer: true }, length: { is: 10 }
  validates :pincode, presence: true, format: { with: /\A[1-9][0-9]{5}\z/, message: 'must be a valid 6-digit Indian PIN code' }

  private

  def titleize_address_fields
    self.name = titleize_string(name)
    self.address = titleize_string(address)
    self.state = titleize_string(state)
    self.district = titleize_string(district)
  end

  def titleize_string(str)
		str.to_s.titleize if str.present?
	end
end
