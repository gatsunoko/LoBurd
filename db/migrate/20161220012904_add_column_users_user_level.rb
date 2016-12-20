class AddColumnUsersUserLevel < ActiveRecord::Migration[5.0]
  def change
  	add_column :users, :user_level, :integer
  end
end
