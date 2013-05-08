class RenamePostTracksToPostsTracks < ActiveRecord::Migration
   def change
  	rename_table :post_tracks, :posts_tracks
  end 
end
