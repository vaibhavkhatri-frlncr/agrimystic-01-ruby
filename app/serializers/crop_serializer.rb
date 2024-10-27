class CropSerializer < BaseSerializer
  attributes :name

  attribute :crop_image do |crop|
    base_url + Rails.application.routes.url_helpers.rails_blob_path(crop.crop_image, only_path: true) if crop.crop_image.attached?
  end

  attributes :created_at, :updated_at
end
