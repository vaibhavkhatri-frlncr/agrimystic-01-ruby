class OrderProduct < ActiveRecord::Migration[7.1]
  def change
    create_table "order_products", force: :cascade do |t|
      t.references :order, null: false, foreign_key: true
      t.bigint "product_variant_id", null: false
      t.integer "quantity", null: false, default: 1
      t.decimal "price", null: false
      t.decimal "total_price", default: 0.0

      t.timestamps
    end
  end
end
