class CreateParts < ActiveRecord::Migration[6.0]
  def change
    create_table :parts do |t|
      t.string :name
      t.float :cost
      t.float :mass

      t.timestamps
    end
  end
end
