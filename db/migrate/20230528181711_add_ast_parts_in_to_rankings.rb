class AddAstPartsInToRankings < ActiveRecord::Migration[6.0]
  def change
    add_column :rankings, :ast_parts_in, :integer
    Ranking.update_all(ast_parts_in: 0)
  end
end
