class Stage < ApplicationRecord
  belongs_to :crop_schedule
  has_many :stage_details, dependent: :destroy

  accepts_nested_attributes_for :stage_details, allow_destroy: true

  validates :title, presence: true
  validate :validate_stage_title

  validate :must_have_at_least_one_stage_detail

  before_validation :titleize_title

  private

  def titleize_title
    self.title = title.to_s.titleize if title.present?
  end

  def must_have_at_least_one_stage_detail
    errors.add(:base, 'Stage must have at least one stage detail.') if stage_details.empty?
  end

  def validate_stage_title
    value = title.to_s.strip

    return if value.blank?

    if value.length < 2
      errors.add(:title, "is too short (minimum is 2 characters)")
      return
    end

    if value.length > 50
      errors.add(:title, "is too long (maximum is 50 characters)")
      return
    end
  end
end
