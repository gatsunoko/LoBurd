class AddColumnCommentsStarrankscore < ActiveRecord::Migration[5.0]
  def change
  	add_column :comments, :star_rank_score, :integer
  end
end
