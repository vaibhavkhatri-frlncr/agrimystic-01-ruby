class CropDiseaseSerializer < BaseSerializer
  attributes :crop, :name, :cause, :solution, :products_recommended

  attribute :disease_image do |crop_disease|
    base_url + Rails.application.routes.url_helpers.rails_blob_path(crop_disease.disease_image, only_path: true) if crop_disease.disease_image.attached?
  end

  attributes :created_at, :updated_at
end
