class AddDamageToRecords < ActiveRecord::Migration[6.0]
  def change
    add_column :records, :dmg_in, :integer
    add_column :records, :dmg_out, :integer
    Record.update_all(dmg_in: 0, dmg_out: 0)
  end
end
