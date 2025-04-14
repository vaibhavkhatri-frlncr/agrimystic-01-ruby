class CreateEmailOtps < ActiveRecord::Migration[7.1]
  def change
    create_table :email_otps do |t|
      t.string :email
      t.integer :pin
      t.boolean :activated, default: false, null: false
      t.datetime :valid_until

      t.timestamps
    end
  end
end
