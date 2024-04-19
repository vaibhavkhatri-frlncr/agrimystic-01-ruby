class District < ApplicationRecord
  self.table_name = :districts

  belongs_to :state
  has_many :villages, dependent: :destroy

  accepts_nested_attributes_for :villages, allow_destroy: true

  validates :name, uniqueness: true, presence: true
end
