class AddDiscardedAtToVessels < ActiveRecord::Migration[6.0]
  def change
    add_column :vessels, :discarded_at, :datetime
    add_index :vessels, :discarded_at
  end
end
