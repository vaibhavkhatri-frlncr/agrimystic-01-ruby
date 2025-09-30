class UpdateCartsForFarmerSti < ActiveRecord::Migration[7.1]
  def change
    remove_reference :carts, :account, foreign_key: true, index: true

    add_reference :carts, :farmer, null: false, foreign_key: { to_table: :accounts }, index: true
  end
end
