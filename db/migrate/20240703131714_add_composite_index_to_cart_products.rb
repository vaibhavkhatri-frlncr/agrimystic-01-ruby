class AddCompositeIndexToCartProducts < ActiveRecord::Migration[7.1]
  def change
    add_index :cart_products, [:cart_id, :product_variant_id], unique: true, name: 'index_cart_products_on_cart_id_and_product_variant_id'
  end
end
