class Category < ApplicationRecord
  self.table_name = :categories

  include RansackSearchable

  has_many :products, dependent: :destroy

  validates :name, uniqueness: true, presence: true
end
