class RenameIdentifyDiseasesToCropDiseases < ActiveRecord::Migration[7.1]
  def change
    rename_table :identify_diseases, :crop_diseases
  end
end
