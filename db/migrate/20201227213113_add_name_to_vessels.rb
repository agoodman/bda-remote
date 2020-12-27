class AddNameToVessels < ActiveRecord::Migration[6.0]
  def change
    add_column :vessels, :name, :string
  end

  def data
    Vessel.find_each do |v|
      v.name = "Vessel#{v.id}"
      v.save!
    end
  end
end
