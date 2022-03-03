class AddPlayersPerHeatToCompetitions < ActiveRecord::Migration[6.0]
  def change
    add_column :competitions, :max_players_per_heat, :integer
    Competition.update_all(max_players_per_heat: 8)
  end
end
