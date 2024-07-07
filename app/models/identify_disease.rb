class IdentifyDisease < ApplicationRecord
  self.table_name = :identify_diseases

  has_one_attached :disease_image

  validates :disease_name, :disease_cause, :solution, :products_recommended, presence: true
  validates_presence_of :disease_image, message: 'disease image must be attached', on: :create
end
