class RemoveColumnUsersEmail < ActiveRecord::Migration[5.0]
  def down
  	remove_column :users, :email, :string
  end
end
