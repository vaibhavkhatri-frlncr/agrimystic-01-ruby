class Orders < ActiveRecord::Migration[7.1]
  def change
    create_table "orders", force: :cascade do |t|
      t.references :account, null: false, foreign_key: true
      t.references :address, null: false, foreign_key: true
      t.string "payment_method"
      t.string "payment_status", default: 'pending'
      t.string "order_status", default: 'placed'
      t.decimal "total_amount", default: 0.0
      t.string "razorpay_order_id"
      t.string "razorpay_payment_id"
      t.datetime "placed_at"
      t.datetime "cancelled_at"
      t.datetime "paid_at"

      t.timestamps
    end
  end
end
