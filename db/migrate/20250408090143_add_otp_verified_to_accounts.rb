class AddOtpVerifiedToAccounts < ActiveRecord::Migration[7.1]
  def change
    add_column :accounts, :otp_verified, :boolean, default: false, null: false
    change_column_default :accounts, :activated, from: false, to: true
  end
end
