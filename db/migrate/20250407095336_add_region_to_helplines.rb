class AddRegionToHelplines < ActiveRecord::Migration[7.1]
  def change
    add_column :helplines, :region, :string
  end
end
