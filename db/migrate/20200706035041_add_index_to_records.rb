class AddIndexToRecords < ActiveRecord::Migration[6.0]
  def change
    add_index :records, [:competition_id, :player]
  end
end
