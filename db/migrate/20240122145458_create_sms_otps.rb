class CreateSmsOtps < ActiveRecord::Migration[6.0]
  def change
    create_table :sms_otps do |t|
      t.string :full_phone_number
      t.integer :pin
      t.boolean :activated, null: false, default: false
      t.timestamp :valid_until

      t.timestamps
    end
  end
end
