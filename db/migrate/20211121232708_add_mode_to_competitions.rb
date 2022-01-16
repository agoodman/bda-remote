class AddModeToCompetitions < ActiveRecord::Migration[6.0]
  def change
    add_column :competitions, :mode, :string
  end
end
