class AddPublishedAtToCompetitions < ActiveRecord::Migration[6.0]
  def change
    add_column :competitions, :published_at, :datetime
    Competition.update_all("published_at = created_at")
  end
end
