class AddCropToIdentifyDiseases < ActiveRecord::Migration[7.1]
  def change
    add_reference :identify_diseases, :crop, foreign_key: true
  end
end
