class AddressSerializer < BaseSerializer
  attributes :name, :mobile, :address, :pincode, :state, :district, :address_type, :default_address
end
