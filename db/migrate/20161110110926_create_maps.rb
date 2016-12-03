class CreateMaps < ActiveRecord::Migration[5.0]
  def change
    create_table :maps do |t|
      t.integer :user_id
      t.string :title
      t.string :address
      t.float :latitude
      t.float :longitude

      t.timestamps
    end
  end
end
