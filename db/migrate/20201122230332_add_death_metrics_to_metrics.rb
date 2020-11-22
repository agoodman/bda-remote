class AddDeathMetricsToMetrics < ActiveRecord::Migration[6.0]
  def change
    add_column :metrics, :death_order, :float
    add_column :metrics, :death_time, :float
    add_column :metrics, :wins, :integer
    Metric.update_all(death_order: 0, death_time: 0, wins: 0)
  end
end
