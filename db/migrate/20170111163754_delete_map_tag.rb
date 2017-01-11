class DeleteMapTag < ActiveRecord::Migration[5.0]
  def change
    drop_table :map_tags
  end
end
