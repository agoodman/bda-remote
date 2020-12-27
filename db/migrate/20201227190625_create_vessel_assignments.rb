class CreateVesselAssignments < ActiveRecord::Migration[6.0]
  def change
    create_table :vessel_assignments do |t|
      t.integer :competition_id
      t.integer :vessel_id

      t.timestamps
    end

    Vessel.find_each do |v|
      VesselAssignment.create(competition_id: v.competition_id, vessel_id: v.id)
    end
    remove_column :vessels, :competition_id
  end
end
