class CreateProductVariants < ActiveRecord::Migration[6.0]
  def change
    create_table :product_variants do |t|
      t.references :product, null: false, foreign_key: true
      t.string :size
      t.decimal :price
      t.integer :quantity
      t.decimal :total_price, default: 0

      t.timestamps
    end
  end
end
