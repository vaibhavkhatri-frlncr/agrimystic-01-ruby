class CreateFarmerCropNames < ActiveRecord::Migration[7.1]
  def change
    create_table :farmer_crop_names do |t|
      t.string :name

      t.timestamps
    end
  end
end
