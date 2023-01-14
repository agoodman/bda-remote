class AddLiftAreaToParts < ActiveRecord::Migration[6.0]
  def change
    add_column :parts, :lift_area, :float
    Part.update_all(lift_area: 0)
  end
end
