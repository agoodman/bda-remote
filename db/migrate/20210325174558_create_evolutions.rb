class CreateEvolutions < ActiveRecord::Migration[6.0]
  def change
    create_table :evolutions do |t|
      t.string :name
      t.integer :vessel_id
      t.integer :user_id
      t.integer :max_generations

      t.timestamps
    end
    add_index :evolutions, :user_id
    add_index :evolutions, :vessel_id
  end
end
