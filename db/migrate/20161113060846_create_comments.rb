class CreateComments < ActiveRecord::Migration[5.0]
  def change
    create_table :comments do |t|
      t.integer :user_id
      t.integer :map_id
      t.string :title
      t.text :text

      t.timestamps
    end
  end
end
