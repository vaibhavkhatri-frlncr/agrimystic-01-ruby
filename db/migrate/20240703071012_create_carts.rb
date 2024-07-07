class CreateCarts < ActiveRecord::Migration[7.1]
  def change
    create_table :carts do |t|
      t.references :account, null: false, foreign_key: true
      t.decimal :total_price, default: 0

      t.timestamps
    end
  end
end
