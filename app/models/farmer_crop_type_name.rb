class FarmerCropTypeName < ApplicationRecord
  self.table_name = :farmer_crop_type_names

  belongs_to :farmer_crop_name

  validates :name, presence: true, uniqueness: { scope: :farmer_crop_name_id, case_sensitive: false }
end
