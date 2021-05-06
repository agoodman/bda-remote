class AddRolesMaskToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :roles_mask, :integer
    User.update_all(roles_mask: 0)
  end
end
