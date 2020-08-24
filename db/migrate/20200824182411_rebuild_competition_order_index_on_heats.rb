class RebuildCompetitionOrderIndexOnHeats < ActiveRecord::Migration[6.0]
  def change
    remove_index :heats, [:competition_id, :order]
    add_index :heats, [:competition_id, :stage, :order]
  end
end
