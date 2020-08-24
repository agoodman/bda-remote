class AddRemainingStagesToCompetitions < ActiveRecord::Migration[6.0]
  def change
    add_column :competitions, :remaining_stages, :integer
  end
end
