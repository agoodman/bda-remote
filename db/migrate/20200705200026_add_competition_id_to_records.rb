class AddCompetitionIdToRecords < ActiveRecord::Migration[6.0]
  def change
    add_column :records, :competition_id, :integer
  end
end
