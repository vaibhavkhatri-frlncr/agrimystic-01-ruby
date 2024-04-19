class CreateAccounts < ActiveRecord::Migration[6.0]
  def change
    create_table :accounts do |t|
      t.string :full_phone_number
      t.integer :country_code
      t.bigint :phone_number
      t.string :full_name
      t.string :first_name
      t.string :last_name
      t.date :date_of_birth
      t.string :address
      t.string :state
      t.string :district
      t.string :village
      t.string :pincode
      t.boolean :activated, null: false, default: false
      t.string :email
      t.integer :gender
      t.string :device_id
      t.text :unique_auth_id
      t.string :password_digest
      t.string :type

      t.timestamps
    end
  end
end
