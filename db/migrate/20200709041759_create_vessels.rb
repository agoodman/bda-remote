class CreateVessels < ActiveRecord::Migration[6.0]
  def change
    create_table :vessels do |t|
      t.integer :player_id
      t.string :craft_url

      t.timestamps
    end
  end
end
