class AddAssistsToRecords < ActiveRecord::Migration[6.0]
  def change
    add_column :records, :assists, :integer
    Record.update_all(assists: 0)
  end
end
