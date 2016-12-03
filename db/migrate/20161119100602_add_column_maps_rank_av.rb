class AddColumnMapsRankAv < ActiveRecord::Migration[5.0]
  def change
  	add_column :maps, :rank_av, :real
  end
end
