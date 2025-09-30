class AddPurposeToEmailOtps < ActiveRecord::Migration[7.1]
  def change
    add_column :email_otps, :purpose, :string
  end
end
