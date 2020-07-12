class AddHeatIdToRecords < ActiveRecord::Migration[6.0]
  def change
    add_column :records, :heat_id, :integer
  end
end
