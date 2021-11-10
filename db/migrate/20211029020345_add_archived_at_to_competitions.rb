class AddArchivedAtToCompetitions < ActiveRecord::Migration[6.0]
  def change
    add_column :competitions, :archived_at, :timestamp
  end
end
