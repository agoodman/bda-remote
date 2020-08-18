# frozen_string_literal: true

class DeviseCreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :name
      t.string :email

      ## Omniauth-Google
      t.string :provider
      t.string :uid

      ## Rememberable
      t.string :remember_token
      t.datetime :remember_created_at

      t.timestamps null: false
    end

    add_index :users, :email,                unique: true
    add_index :users, [:uid, :provider],     unique: true
  end
end
