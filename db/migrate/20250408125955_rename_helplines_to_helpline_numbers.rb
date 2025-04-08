class RenameHelplinesToHelplineNumbers < ActiveRecord::Migration[7.1]
  def change
    rename_table :helplines, :helpline_numbers
  end
end
