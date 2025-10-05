class CropSchedule < ApplicationRecord
  belongs_to :crop
  has_many :stages, dependent: :destroy

  accepts_nested_attributes_for :stages, allow_destroy: true

  before_validation :titleize_heading
  before_update :check_stages
  
  validate :validate_crop_schedule_heading
  validate :must_have_at_least_one_stage
  validate :check_stage_details_before_update, on: [:create, :update]
  validate :unique_crop_schedule

  private

  def titleize_heading
    self.heading = heading.to_s.titleize if heading.present?
  end

  def check_stages
    stages_to_destroy = stages.count(&:marked_for_destruction?)

    if stages_to_destroy > 0 && stages.reject(&:marked_for_destruction?).empty?
      errors.add(:base, 'Crop schedule must have at least one stage.')
      throw(:abort)
    end
  end

  def unique_crop_schedule
    if new_record? || crop_id_changed?
      if CropSchedule.where(crop_id: crop_id).where.not(id: id).exists?
        errors.add(:base, 'Crop schedule for this crop already exist.')
      end
    end
  end

  def must_have_at_least_one_stage
    errors.add(:base, 'Crop schedule must have at least one stage.') if stages.empty?
  end

  def check_stage_details_before_update
    stages_without_details = stages.count { |stage| stage.stage_details.empty? || stage.stage_details.count(&:marked_for_destruction?) == stage.stage_details.size }
  
    if stages_without_details > 0 && stages.reject { |stage| stage.stage_details.empty? || stage.stage_details.count(&:marked_for_destruction?) == stage.stage_details.size }.empty?
      errors.add(:base, 'Each stage must have at least one stage detail.')
      throw(:abort)
    end
  end

  def validate_crop_schedule_heading
    value = heading.to_s.strip

    if value.blank?
      errors.add(:heading, "can't be blank")
      return
    end

    if value.length < 2
      errors.add(:heading, "is too short (minimum is 2 characters)")
      return
    end

    if value.length > 50
      errors.add(:heading, "is too long (maximum is 50 characters)")
      return
    end
  end
end
