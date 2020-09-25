class AddPartsToMetrics < ActiveRecord::Migration[6.0]
  def change
    add_column :metrics, :ram_parts_in, :float
    add_column :metrics, :ram_parts_out, :float
    add_column :metrics, :mis_parts_in, :float
    add_column :metrics, :mis_parts_out, :float
    add_column :metrics, :mis_dmg_in, :float
    add_column :metrics, :mis_dmg_out, :float
    Metric.update_all(
        ram_parts_in: 0,
        ram_parts_out: 0,
        mis_parts_in: 0,
        mis_parts_out: 0,
        mis_dmg_in: 0,
        mis_dmg_out: 0
    )
  end
end
