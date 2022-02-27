class AddWaypointsToRecords < ActiveRecord::Migration[6.0]
  def change
    add_column :records, :waypoints, :integer
    add_column :records, :elapsed_time, :float
    add_column :records, :deviation, :float
    Record.update_all(waypoints: 0, deviation: 0, elapsed_time: 0)
  end
end
