class CreateReviews < ActiveRecord::Migration[7.1]
  def change
    create_table :reviews do |t|
      t.integer :rating
      t.text :review

      t.references :trader, null: false, foreign_key: { to_table: :accounts }
      t.references :farmer_crop, null: false, foreign_key: true

      t.timestamps
    end
  end
end
