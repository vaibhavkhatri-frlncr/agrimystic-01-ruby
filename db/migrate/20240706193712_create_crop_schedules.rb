class CreateCropSchedules < ActiveRecord::Migration[7.1]
  def change
    create_table :crop_schedules do |t|
      t.string :crop
      t.string :heading

      t.timestamps
    end
  end
end
