class AddStartStopToHeats < ActiveRecord::Migration[6.0]
  def change
    add_column :heats, :started_at, :timestamp
    add_column :heats, :ended_at, :timestamp
  end
end
