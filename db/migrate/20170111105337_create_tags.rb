class CreateTags < ActiveRecord::Migration[5.0]
  def change
    create_table :tags do |t|
      t.string :tag_name
      t.boolean :tag_master
      t.integer :map_id

      t.timestamps
    end
  end
end
