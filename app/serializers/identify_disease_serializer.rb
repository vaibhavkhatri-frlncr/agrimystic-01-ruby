class IdentifyDiseaseSerializer < BaseSerializer
  attributes :disease_name, :disease_cause, :solution, :products_recommended

  attribute :disease_image do |identify_disease|
    base_url + Rails.application.routes.url_helpers.rails_blob_path(identify_disease.disease_image, only_path: true) if identify_disease.disease_image.attached?
  end

  attributes :created_at, :updated_at
end
