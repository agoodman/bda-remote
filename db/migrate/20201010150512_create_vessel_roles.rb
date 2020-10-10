class CreateVesselRoles < ActiveRecord::Migration[6.0]
  def change
    create_table :vessel_roles do |t|
      t.integer :competition_id
      t.string :name

      t.timestamps
    end
  end
end
