class AddDistanceIndexToRecords < ActiveRecord::Migration[6.0]
  def change
    add_index :records, :distance
  end
end
