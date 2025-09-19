class CreateFarmerCropTypeNames < ActiveRecord::Migration[7.1]
  def change
    create_table :farmer_crop_type_names do |t|
      t.string :name
      t.references :farmer_crop_name, null: false, foreign_key: true

      t.timestamps
    end
  end
end
