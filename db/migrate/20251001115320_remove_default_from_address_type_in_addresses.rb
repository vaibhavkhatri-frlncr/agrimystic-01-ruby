class RemoveDefaultFromAddressTypeInAddresses < ActiveRecord::Migration[7.1]
  def change
    change_column_default :addresses, :address_type, from: 0, to: nil
  end
end
