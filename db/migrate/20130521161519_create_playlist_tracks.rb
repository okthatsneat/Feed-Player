class CreatePlaylistTracks < ActiveRecord::Migration
  def change
    create_table :playlist_tracks do |t|
    	t.integer :position
    	t.references :playlist
    	t.references :track
    	t.timestamps
    end
  end
end
