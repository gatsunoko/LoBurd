class AddColumnPicturesPicturePath2 < ActiveRecord::Migration[5.0]
  def change
  	add_column :pictures, :picture_path, :text
  end
end
