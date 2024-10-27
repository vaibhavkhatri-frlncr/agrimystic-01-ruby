class Category < ApplicationRecord
  self.table_name = :categories

  has_many :products, dependent: :destroy

  validates :name, presence: true, uniqueness: { case_sensitive: false }, length: { maximum: 50 }
end
