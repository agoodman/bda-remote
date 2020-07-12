class AddNameIndexToCompetition < ActiveRecord::Migration[6.0]
  def change
    add_index :competitions, :name, unique: true
  end
end
