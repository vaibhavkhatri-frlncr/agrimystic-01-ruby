class Trader < Account
  has_many :reviews, dependent: :destroy
end
