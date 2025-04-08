class CropDisease < ApplicationRecord
  self.table_name = :crop_diseases

  belongs_to :crop
  has_one_attached :disease_image

  validates :disease_name, :disease_cause, :solution, :products_recommended, presence: true
  validate :disease_image_presence
  validate :disease_image_format
  validate :unique_disease_name_for_crop

  private

  def disease_image_presence
    errors.add(:disease_image, 'must be attached') unless disease_image.attached?
  end

  def disease_image_format
    errors.add(:disease_image, 'must be a PNG, JPG, or JPEG') if disease_image.attached? && !disease_image.content_type.in?(%w[image/png image/jpg image/jpeg])
  end

  def unique_disease_name_for_crop
    if CropDisease.where(crop_id: crop_id)
      .where('LOWER(disease_name) = ?', disease_name.downcase)
      .where.not(id: id)
      .exists?
      errors.add(:disease_name, 'this crop already has a disease entry with the same name')
    end
  end
end
