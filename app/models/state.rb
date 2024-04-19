class State < ApplicationRecord
  self.table_name = :states

  has_many :districts, dependent: :destroy
  has_many :villages, through: :districts

  accepts_nested_attributes_for :districts, allow_destroy: true
  accepts_nested_attributes_for :villages, allow_destroy: true, reject_if: :all_blank

  validates :name, uniqueness: true, presence: true
end
