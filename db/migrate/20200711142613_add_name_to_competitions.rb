class AddNameToCompetitions < ActiveRecord::Migration[6.0]
  def change
    add_column :competitions, :name, :string
  end
end
