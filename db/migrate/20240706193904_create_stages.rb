class CreateStages < ActiveRecord::Migration[7.1]
  def change
    create_table :stages do |t|
      t.references :crop_schedule, null: false, foreign_key: true
      t.string :title

      t.timestamps
    end
  end
end
