class Trader < Account
  has_many :reviews, dependent: :destroy
  has_many :enquiries, dependent: :destroy
end
