class AddSelectionStrategyToVariantGroups < ActiveRecord::Migration[6.0]
  def change
    add_column :variant_groups, :selection_strategy, :string
    VariantGroup.update_all(selection_strategy: "best")
  end
end
