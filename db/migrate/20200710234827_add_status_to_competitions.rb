class AddStatusToCompetitions < ActiveRecord::Migration[6.0]
  def change
    add_column :competitions, :status, :integer
  end
end
