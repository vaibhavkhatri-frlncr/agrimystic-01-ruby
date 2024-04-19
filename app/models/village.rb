class Village < ApplicationRecord
  self.table_name = :villages

  belongs_to :district

  validates :name, presence: true
  validates :pincode, presence: true, length: { is: 6 }
end
