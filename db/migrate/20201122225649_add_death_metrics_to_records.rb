class AddDeathMetricsToRecords < ActiveRecord::Migration[6.0]
  def change
    add_column :records, :death_order, :float
    add_column :records, :death_time, :float
    Record.update_all(death_order: 0, death_time: 0)
  end
end
