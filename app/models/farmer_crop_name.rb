class FarmerCropName < ApplicationRecord
  self.table_name = :farmer_crop_names

  has_many :farmer_crop_type_names, dependent: :destroy

  accepts_nested_attributes_for :farmer_crop_type_names, allow_destroy: true, reject_if: :all_blank

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
