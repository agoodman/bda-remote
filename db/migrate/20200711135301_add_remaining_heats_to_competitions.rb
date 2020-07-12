class AddRemainingHeatsToCompetitions < ActiveRecord::Migration[6.0]
  def change
    add_column :competitions, :remaining_heats, :integer
  end
end
