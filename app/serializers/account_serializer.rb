class AccountSerializer < BaseSerializer
  attributes :first_name, :last_name, :full_name, :country_code, :phone_number, :full_phone_number, :email, :date_of_birth, :address, :state, :district, :village, :pincode, :activated

  attribute :profile_image do |account|
    base_url + Rails.application.routes.url_helpers.rails_blob_path(account.profile_image, only_path: true) if account.profile_image.attached?
  end

  attributes :created_at, :updated_at
end
