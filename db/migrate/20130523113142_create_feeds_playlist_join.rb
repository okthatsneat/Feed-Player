class CreateFeedsPlaylistJoin < ActiveRecord::Migration
  def change
  	create_table :feeds_playlists, :id => false do |t|    	
    	t.references :playlist
    	t.references :feed
    	t.timestamps
    end
  end
end
