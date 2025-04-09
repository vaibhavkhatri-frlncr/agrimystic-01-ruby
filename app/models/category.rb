class Category < ApplicationRecord
  self.table_name = :categories

  has_many :products, dependent: :destroy

  validates :name, presence: true, uniqueness: { case_sensitive: false }, length: { maximum: 50 }

  before_validation :titleize_name

  private

  def titleize_name
    self.name = name.to_s.titleize if name.present?
  end
end
