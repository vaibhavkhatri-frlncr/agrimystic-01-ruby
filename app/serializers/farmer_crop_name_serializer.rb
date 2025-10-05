class FarmerCropNameSerializer < BaseSerializer
  attributes :name
  
  attribute :crop_image do |farmer_crop_name|
    base_url + Rails.application.routes.url_helpers.rails_blob_path(farmer_crop_name.crop_image, only_path: true) if farmer_crop_name.crop_image.attached?
  end

  attributes :created_at, :updated_at, :farmer_crop_type_names
end
