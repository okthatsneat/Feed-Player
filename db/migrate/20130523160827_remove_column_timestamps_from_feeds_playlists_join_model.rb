class RemoveColumnTimestampsFromFeedsPlaylistsJoinModel < ActiveRecord::Migration
  def change
	  remove_column :feeds_playlists, :timestamps

  end
end
