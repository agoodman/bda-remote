class AddUserIdToPlayers < ActiveRecord::Migration[6.0]
  def change
    add_column :players, :user_id, :integer
  end
end
