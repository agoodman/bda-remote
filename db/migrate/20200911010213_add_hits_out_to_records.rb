class AddHitsOutToRecords < ActiveRecord::Migration[6.0]
  def change
    rename_column :records, :hits, :hits_out
    add_column :records, :hits_in, :integer
    Record.update_all(hits_in: 0)
  end
end
