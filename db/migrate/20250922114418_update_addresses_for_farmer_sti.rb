class UpdateAddressesForFarmerSti < ActiveRecord::Migration[7.1]
  def change
    remove_reference :addresses, :account, foreign_key: true, index: true

    add_reference :addresses, :farmer, null: false, foreign_key: { to_table: :accounts }, index: true
  end
end
