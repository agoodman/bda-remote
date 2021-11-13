class AddRocketStatsToRankings < ActiveRecord::Migration[6.0]
  def change
    add_column :rankings, :roc_parts_in, :integer
    add_column :rankings, :roc_parts_out, :integer
    add_column :rankings, :roc_dmg_in, :float
    add_column :rankings, :roc_dmg_out, :float
    Ranking.update_all(roc_parts_in: 0, roc_parts_out: 0, roc_dmg_in: 0, roc_dmg_out: 0)
  end
end
