class CreateVariantAssignments < ActiveRecord::Migration[6.0]
  def change
    create_table :variant_assignments do |t|
      t.integer :variant_id
      t.integer :vessel_id

      t.timestamps
    end
  end
end
