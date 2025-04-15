class AddPurposeToSmsOtps < ActiveRecord::Migration[7.1]
  def change
    add_column :sms_otps, :purpose, :string
  end
end
