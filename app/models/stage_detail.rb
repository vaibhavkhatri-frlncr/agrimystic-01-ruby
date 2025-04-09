class StageDetail < ApplicationRecord
  self.table_name = :stage_details

  belongs_to :stage

  validates :product_to_use, :benefits, presence: true

  before_validation :capitalize_stage_detail_fields

  private

  def capitalize_stage_detail_fields
    self.product_to_use = capitalize_string(product_to_use)
    self.benefits = capitalize_string(benefits)
  end

  def capitalize_string(str)
    str.to_s.capitalize if str.present?
  end
end
