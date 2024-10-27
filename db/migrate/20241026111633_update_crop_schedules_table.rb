class UpdateCropSchedulesTable < ActiveRecord::Migration[7.1]
  def change
    remove_column :crop_schedules, :crop, :string
    add_reference :crop_schedules, :crop, foreign_key: true
  end
end
