class AddPointsToParts < ActiveRecord::Migration[6.0]
  def change
    add_column :parts, :points, :integer
  end
end
