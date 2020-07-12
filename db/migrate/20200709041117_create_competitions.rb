class CreateCompetitions < ActiveRecord::Migration[6.0]
  def change
    create_table :competitions do |t|
      t.timestamp :started_at
      t.timestamp :ended_at

      t.timestamps
    end
  end
end
