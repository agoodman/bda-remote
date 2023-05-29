class AddAstPartsInToRecords < ActiveRecord::Migration[6.0]
  def change
    add_column :records, :ast_parts_in, :integer
    Record.update_all(ast_parts_in: 0)
  end
end
