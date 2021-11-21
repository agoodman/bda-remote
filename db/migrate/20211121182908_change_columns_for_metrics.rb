class ChangeColumnsForMetrics < ActiveRecord::Migration[6.0]
  def change
    change_column :metrics, :wins, :float
    change_column :metrics, :roc_parts_in, :float
    change_column :metrics, :roc_parts_out, :float
  end
end
