class RemoveIndexOnRecords < ActiveRecord::Migration[6.0]
  def change
    remove_index :records, :competition_id
    add_index :records, [:competition_id, :heat_id, :vessel_id], unique: true
  end
end
