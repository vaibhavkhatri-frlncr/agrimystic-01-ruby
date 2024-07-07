class CropSchedule < ApplicationRecord
  self.table_name = :crop_schedules

  has_many :stages, dependent: :destroy
  has_one_attached :crop_image

  accepts_nested_attributes_for :stages, allow_destroy: true

  validates :crop, presence: true
  validates :heading, presence: true
  validates_presence_of :crop_image, message: 'crop image must be attached', on: :create
  validate :must_have_at_least_one_stage

  before_update :check_stages_before_update
  validate :check_stage_details_before_update, on: [:create, :update]


  private

  def must_have_at_least_one_stage
    errors.add(:base, 'Crop shedule must have at least one stage') if stages.empty?
  end

  def check_stages_before_update
    stages_to_destroy = stages.count(&:marked_for_destruction?)

    if stages_to_destroy > 0 && stages.reject(&:marked_for_destruction?).empty?
      errors.add(:base, 'Crop schedule must have at least one stage')
      throw(:abort)
    end
  end

  def check_stage_details_before_update
    stages_without_details = stages.count { |stage| stage.stage_details.empty? || stage.stage_details.count(&:marked_for_destruction?) == stage.stage_details.size }
  
    if stages_without_details > 0 && stages.reject { |stage| stage.stage_details.empty? || stage.stage_details.count(&:marked_for_destruction?) == stage.stage_details.size }.empty?
      errors.add(:base, 'Each stage must have at least one stage detail')
      throw(:abort)
    end
  end
end
