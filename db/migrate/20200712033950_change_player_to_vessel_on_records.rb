class ChangePlayerToVesselOnRecords < ActiveRecord::Migration[6.0]
  def change
    remove_column :records, :player_id
    add_column :records, :vessel_id, :integer
  end
end
