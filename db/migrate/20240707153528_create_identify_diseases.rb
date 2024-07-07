class CreateIdentifyDiseases < ActiveRecord::Migration[7.1]
  def change
    create_table :identify_diseases do |t|
      t.string :disease_name
      t.text :disease_cause
      t.text :solution
      t.string :products_recommended

      t.timestamps
    end
  end
end
