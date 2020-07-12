class AddNameIndexToPlayers < ActiveRecord::Migration[6.0]
  def change
    add_index :players, :name, unique: true
  end
end
