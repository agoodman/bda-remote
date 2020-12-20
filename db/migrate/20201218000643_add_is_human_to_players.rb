class AddIsHumanToPlayers < ActiveRecord::Migration[6.0]
  def change
    add_column :players, :is_human, :boolean, default: true
  end
end
