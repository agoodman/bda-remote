class CreateRecords < ActiveRecord::Migration[6.0]
  def change
    create_table :records do |t|
      t.string :player
      t.integer :hits
      t.integer :kills
      t.integer :deaths
      t.float :distance
      t.string :weapon

      t.timestamps
    end
  end
end
