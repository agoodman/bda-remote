class AddRoleToVessels < ActiveRecord::Migration[6.0]
  def change
    add_column :vessels, :role, :string
    Vessel.update_all(role: "default")
  end
end
