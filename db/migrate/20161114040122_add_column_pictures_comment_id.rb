class AddColumnPicturesCommentId < ActiveRecord::Migration[5.0]
  def up
  	add_column :pictures, :comment_id, :integer
  end
end
