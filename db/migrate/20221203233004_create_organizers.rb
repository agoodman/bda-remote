class CreateOrganizers < ActiveRecord::Migration[6.0]
  def change
    create_table :organizers do |t|
      t.integer :user_id
      t.integer :competition_id

      t.timestamps
    end
  end
end
