class CreateProducts < ActiveRecord::Migration[6.0]
  def change
    create_table :products do |t|
      t.references :category, null: false, foreign_key: true
      t.string :name
      t.text :description
      t.string :code
      t.decimal :total_price, default: 0

      t.timestamps
    end
  end
end
