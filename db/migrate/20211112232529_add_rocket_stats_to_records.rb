class AddRocketStatsToRecords < ActiveRecord::Migration[6.0]
  def change
    add_column :records, :roc_parts_in, :integer
    add_column :records, :roc_parts_out, :integer
    add_column :records, :roc_dmg_in, :float
    add_column :records, :roc_dmg_out, :float
    Record.update_all(roc_parts_in: 0, roc_parts_out: 0, roc_dmg_in: 0, roc_dmg_out: 0)
  end
end
