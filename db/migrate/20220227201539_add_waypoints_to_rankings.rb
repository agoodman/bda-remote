class AddWaypointsToRankings < ActiveRecord::Migration[6.0]
  def change
    add_column :rankings, :waypoints, :integer
    add_column :rankings, :elapsed_time, :float
    add_column :rankings, :deviation, :float
    Ranking.update_all(waypoints: 0, deviation: 0, elapsed_time: 0)
  end
end
