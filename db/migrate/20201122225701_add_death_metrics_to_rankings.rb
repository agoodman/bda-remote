class AddDeathMetricsToRankings < ActiveRecord::Migration[6.0]
  def change
    add_column :rankings, :death_order, :float
    add_column :rankings, :death_time, :float
    add_column :rankings, :wins, :integer
    Ranking.update_all(death_order: 0, death_time: 0, wins: 0)
  end
end
