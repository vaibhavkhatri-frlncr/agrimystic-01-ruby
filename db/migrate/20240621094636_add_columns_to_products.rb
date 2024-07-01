class AddColumnsToProducts < ActiveRecord::Migration[7.1]
  def change
    add_column :products, :manufacturer, :string
    add_column :products, :dosage, :string
    add_column :products, :features, :string
  end
end
