class UpdateOrdersForFarmerSti < ActiveRecord::Migration[7.1]
  def change
    remove_reference :orders, :account, foreign_key: true, index: true

    add_reference :orders, :farmer, null: false, foreign_key: { to_table: :accounts }, index: true
  end
end
