class CreateRankings < ActiveRecord::Migration[6.0]
  def change
    create_table :rankings do |t|
      t.integer :vessel_id
      t.integer :competition_id
      t.integer :rank
      t.float :score
      t.integer :kills
      t.integer :deaths
      t.integer :assists
      t.integer :hits_out
      t.integer :hits_in
      t.float :dmg_out
      t.float :dmg_in

      t.timestamps
    end
    add_index :rankings, [:competition_id, :vessel_id]
  end
end
