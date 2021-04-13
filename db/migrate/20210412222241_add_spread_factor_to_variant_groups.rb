class AddSpreadFactorToVariantGroups < ActiveRecord::Migration[6.0]
  def change
    add_column :variant_groups, :spread_factor, :float
    VariantGroup.update_all('spread_factor = 0.25 / (generation + 1)')
  end
end
