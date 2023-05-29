class AddAstPartsInToMetrics < ActiveRecord::Migration[6.0]
  def change
    add_column :metrics, :ast_parts_in, :float
    Metric.update_all(ast_parts_in: 0)
  end
end
