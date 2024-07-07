class AddDefaultValueToQuantityInProductVariants < ActiveRecord::Migration[7.1]
  def change
    change_column_default :product_variants, :quantity, 0
  end
end
