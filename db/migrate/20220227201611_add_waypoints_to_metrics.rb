class AddWaypointsToMetrics < ActiveRecord::Migration[6.0]
  def change
    add_column :metrics, :waypoints, :integer
    add_column :metrics, :elapsed_time, :float
    add_column :metrics, :deviation, :float
    Metric.update_all(waypoints: 0, deviation: 0, elapsed_time: 0)
  end
end
