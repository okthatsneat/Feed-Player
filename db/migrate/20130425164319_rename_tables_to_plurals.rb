class RenameTablesToPlurals < ActiveRecord::Migration
  def change
  	rename_table :keyword_post, :keyword_posts
  	rename_table :keyword_track, :keyword_tracks
  end 
end
