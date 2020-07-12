class CreateHeatAssignments < ActiveRecord::Migration[6.0]
  def change
    create_table :heat_assignments do |t|
      t.integer :heat_id
      t.integer :vessel_id

      t.timestamps
    end
  end
end
