class CreateHeats < ActiveRecord::Migration[6.0]
  def change
    create_table :heats do |t|
      t.integer :competition_id
      t.integer :stage

      t.timestamps
    end
  end
end
