class AddSecretKeyToCompetitions < ActiveRecord::Migration[6.0]
  def change
    add_column :competitions, :secret_key, :string
    Competition.update_all(secret_key: 'c0decafe')
  end
end
