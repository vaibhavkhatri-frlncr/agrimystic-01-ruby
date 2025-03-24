class AccountSerializer < BaseSerializer
  attributes :first_name, :last_name, :full_name, :country_code, :phone_number, :full_phone_number, :date_of_birth, :address, :state, :district, :village, :pincode, :activated, :created_at, :updated_at
end
