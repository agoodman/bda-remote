class AddIndexToVessels < ActiveRecord::Migration[6.0]
  def change
    add_index :vessels, [:player_id, :name], unique: true
  end
end
