class CreateVariantGroupAssignments < ActiveRecord::Migration[6.0]
  def change
    create_table :variant_group_assignments do |t|
      t.integer :variant_group_id
      t.integer :competition_id

      t.timestamps
    end
  end
end
