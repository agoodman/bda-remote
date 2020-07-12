class AddPlayerIdToRecords < ActiveRecord::Migration[6.0]
  def change
    add_column :records, :player_id, :integer

    # create new rows for the existing player names and associate them with the records
    Record.find_each do |r|
      p = Player.where(name: r.player).first_or_create
      p.save
      r.player_id = p.id
      r.save
    end 
  end
end
