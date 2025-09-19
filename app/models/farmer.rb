class Farmer < Account
  self.table_name = :accounts

  has_many :farmer_crops, dependent: :destroy
end
