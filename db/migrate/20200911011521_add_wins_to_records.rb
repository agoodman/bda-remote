class AddWinsToRecords < ActiveRecord::Migration[6.0]
  def change
    add_column :records, :wins, :integer
    Record.update_all(wins: 0)
  end
end
