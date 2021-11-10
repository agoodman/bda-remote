class AddMaxVesselsPerPlayerToCompetitions < ActiveRecord::Migration[6.0]
  def change
    add_column :competitions, :max_vessels_per_player, :integer
    Competition.update_all(max_vessels_per_player: 0)
  end
end
