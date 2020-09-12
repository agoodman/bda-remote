class CreateMetrics < ActiveRecord::Migration[6.0]
  def change
    create_table :metrics do |t|
      t.integer :competition_id
      t.float :kills
      t.float :deaths
      t.float :assists
      t.float :hits_out
      t.float :hits_in
      t.float :dmg_out
      t.float :dmg_in

      t.timestamps
    end
    add_index :metrics, [:competition_id]

    Competition.find_each { |e| e.create_default_metric }
  end
end
