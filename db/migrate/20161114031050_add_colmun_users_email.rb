class AddColmunUsersEmail < ActiveRecord::Migration[5.0]
  def up
  	add_column :users, :email, :string
  end
end
