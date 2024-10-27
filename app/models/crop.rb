class Crop < ApplicationRecord
  self.table_name = :crops

  has_one_attached :crop_image
  has_one :crop_schedule, dependent: :destroy
  has_many :identify_diseases, dependent: :destroy

  validates :name, presence: true, uniqueness: { case_sensitive: false }, length: { maximum: 50 }
  validate :crop_image_presence
  validate :crop_image_format

  private

  def crop_image_presence
    errors.add(:crop_image, 'must be attached') unless crop_image.attached?
  end

  def crop_image_format
    errors.add(:crop_image, 'must be a PNG, JPG, or JPEG') if crop_image.attached? && !crop_image.content_type.in?(%w[image/png image/jpg image/jpeg])
  end
end
