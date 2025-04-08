class CreateAddresses < ActiveRecord::Migration[7.1]
  def change
    create_table :addresses do |t|
      t.string :name
      t.bigint :mobile
      t.string :pincode
      t.string :state
      t.string :address
      t.string :district
      t.integer :address_type, null: false, default: 0
      t.boolean :default_address, default: false
      
      t.references :account, null: false, foreign_key: true

      t.timestamps
    end
  end
end
