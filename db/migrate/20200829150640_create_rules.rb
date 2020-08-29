class CreateRules < ActiveRecord::Migration[6.0]
  def change
    create_table :rules do |t|
      t.integer :competition_id
      t.string :strategy
      t.string :params

      t.timestamps
    end
  end
end
