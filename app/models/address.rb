class Address < ApplicationRecord
  belongs_to :account

  enum address_type: { home: 0, office: 1, other: 2 }

  validates :name, :mobile, :pincode, :state, :address, :district, presence: true
  validates :mobile, numericality: { only_integer: true }, length: { is: 10 }
  validates :pincode, length: { is: 6 }
end
