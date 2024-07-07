class StageDetail < ApplicationRecord
  self.table_name = :stage_details

  belongs_to :stage

  validates :product_to_use, presence: true
  validates :benefits, presence: true
end
