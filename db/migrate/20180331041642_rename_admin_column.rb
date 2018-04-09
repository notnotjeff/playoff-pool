class RenameAdminColumn < ActiveRecord::Migration[5.1]
  def change
    rename_column :leagues, :admin_id, :user_id
  end
end
