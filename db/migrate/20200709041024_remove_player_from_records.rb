class RemovePlayerFromRecords < ActiveRecord::Migration[6.0]
  def change
    remove_index :records, [:competition_id, :player]
    remove_column :records, :player
    add_index :records, [:competition_id, :player_id]
  end
end
