class AddCompetitionIdToVessels < ActiveRecord::Migration[6.0]
  def change
    add_column :vessels, :competition_id, :integer
    add_index :vessels, :competition_id
  end
end
