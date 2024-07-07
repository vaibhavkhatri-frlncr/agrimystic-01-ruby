class Category < ApplicationRecord
  self.table_name = :categories

  has_many :products, dependent: :destroy

  validates :name, uniqueness: true, presence: true
end
