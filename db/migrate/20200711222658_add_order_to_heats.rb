class AddOrderToHeats < ActiveRecord::Migration[6.0]
  def change
    add_column :heats, :order, :integer
    add_index :heats, [:competition_id, :order], unique: true
  end
end
