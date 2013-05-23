class ActuallyRemoveColumnTimestampsFromFeedsPlaylistsJoinModel < ActiveRecord::Migration
  def change
	  remove_column :feeds_playlists, :created_at
	  remove_column :feeds_playlists, :updated_at
  end

end
