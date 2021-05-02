class AddBaselineValuesToVariantGroups < ActiveRecord::Migration[6.0]
  def change
    add_column :variant_groups, :baseline_values, :string
  end
end
