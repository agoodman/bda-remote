class AddSecretKeyToCompetitions < ActiveRecord::Migration[6.0]
  def change
    add_column :competitions, :secret_key, :string
  end
end
