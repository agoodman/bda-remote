class AddPartsToRecords < ActiveRecord::Migration[6.0]
  def change
    add_column :records, :ram_parts_in, :integer
    add_column :records, :ram_parts_out, :integer
    add_column :records, :mis_parts_in, :integer
    add_column :records, :mis_parts_out, :integer
    add_column :records, :mis_dmg_in, :float
    add_column :records, :mis_dmg_out, :float
    Record.update_all(
        ram_parts_in: 0,
        ram_parts_out: 0,
        mis_parts_in: 0,
        mis_parts_out: 0,
        mis_dmg_in: 0,
        mis_dmg_out: 0
    )
  end
end
