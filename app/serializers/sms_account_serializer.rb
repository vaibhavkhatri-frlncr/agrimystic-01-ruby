class SmsAccountSerializer < BaseSerializer
  attributes :first_name, :last_name, :full_phone_number, :country_code, :phone_number, :email, :activated, :created_at, :updated_at
end
