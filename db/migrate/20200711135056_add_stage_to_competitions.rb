class AddStageToCompetitions < ActiveRecord::Migration[6.0]
  def change
    add_column :competitions, :stage, :integer
  end
end
