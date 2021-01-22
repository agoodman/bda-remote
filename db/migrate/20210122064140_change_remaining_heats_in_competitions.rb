class ChangeRemainingHeatsInCompetitions < ActiveRecord::Migration[6.0]
  def change
    rename_column :competitions, :remaining_stages, :max_stages
  end
end
