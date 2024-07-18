class CreateHelplines < ActiveRecord::Migration[7.1]
  def change
    create_table :helplines do |t|
      t.bigint :phone_number

      t.timestamps
    end
  end
end
