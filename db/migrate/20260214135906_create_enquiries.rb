class CreateEnquiries < ActiveRecord::Migration[7.1]
  def change
    create_table :enquiries do |t|
      t.references :farmer_crop, null: false, foreign_key: true
      t.references :trader, null: false, foreign_key: { to_table: :accounts }

      t.text :message, null: false

      t.timestamps
    end
  end
end
