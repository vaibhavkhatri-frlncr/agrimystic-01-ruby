class Stage < ApplicationRecord
  self.table_name = :stages

  belongs_to :crop_schedule
  has_many :stage_details, dependent: :destroy

  accepts_nested_attributes_for :stage_details, allow_destroy: true

  validates :title, presence: true
  validate :must_have_at_least_one_stage_detail

  private

  def must_have_at_least_one_stage_detail
    errors.add(:base, 'Stage must have at least one stage detail') if stage_details.empty?
  end
end
