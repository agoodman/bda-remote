class AddUserIdToCompetitions < ActiveRecord::Migration[6.0]
  def change
    add_column :competitions, :user_id, :integer
  end
end
