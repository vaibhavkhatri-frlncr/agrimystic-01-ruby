class CreateStageDetails < ActiveRecord::Migration[7.1]
  def change
    create_table :stage_details do |t|
      t.references :stage, null: false, foreign_key: true
      t.string :product_to_use
      t.string :benefits

      t.timestamps
    end
  end
end
