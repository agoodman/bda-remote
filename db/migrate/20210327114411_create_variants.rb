class CreateVariants < ActiveRecord::Migration[6.0]
  def change
    create_table :variants do |t|
      t.integer :variant_group_id
      t.string :values

      t.timestamps
    end
    add_index :variants, :variant_group_id
  end
end
