class RenameColumnsInCropDiseases < ActiveRecord::Migration[7.1]
  def change
    rename_column :crop_diseases, :disease_name, :name
    rename_column :crop_diseases, :disease_cause, :cause
  end
end
