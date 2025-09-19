class FarmerCropNameSerializer < BaseSerializer
  attributes :name, :created_at, :updated_at

  attribute :farmer_crop_type_names do |farmer_crop_name|
    farmer_crop_name.farmer_crop_type_names
  end
end
