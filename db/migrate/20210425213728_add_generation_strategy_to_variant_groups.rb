class AddGenerationStrategyToVariantGroups < ActiveRecord::Migration[6.0]
  def change
    add_column :variant_groups, :generation_strategy, :string
    VariantGroup.update_all(generation_strategy: "spread")
  end
end
