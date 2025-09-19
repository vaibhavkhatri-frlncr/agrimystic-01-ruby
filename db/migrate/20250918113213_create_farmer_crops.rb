class CreateFarmerCrops < ActiveRecord::Migration[7.1]
  def change
    create_table :farmer_crops do |t|
      t.string  :variety
      t.text    :description
      t.string  :moisture_content
      t.string  :quantity
      t.string  :price
      t.bigint  :contact_number

      t.references :farmer_crop_name, null: false, foreign_key: true
      t.references :farmer_crop_type_name, null: false, foreign_key: true
      t.references :farmer, null: false, foreign_key: { to_table: :accounts }

      t.timestamps
    end
  end
end
