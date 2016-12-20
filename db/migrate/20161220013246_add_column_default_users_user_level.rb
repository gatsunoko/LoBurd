class AddColumnDefaultUsersUserLevel < ActiveRecord::Migration[5.0]
  def change
  	change_column_default :users, :user_level, 1 
  end
end
