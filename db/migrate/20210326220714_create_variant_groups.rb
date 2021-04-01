class CreateVariantGroups < ActiveRecord::Migration[6.0]
  def change
    create_table :variant_groups do |t|
      t.integer :evolution_id
      t.integer :generation
      t.string :keys

      t.timestamps
    end
    add_index :variant_groups, :evolution_id
  end
end
