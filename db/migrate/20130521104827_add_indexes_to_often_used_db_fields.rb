class AddIndexesToOftenUsedDbFields < ActiveRecord::Migration
  def change
  	add_index :feeds, :feed_url, :unique => true
  	add_index :posts, :guid, :unique => true
		add_index :tracks, :soundcloud_uri, :unique => true
		add_index :tracks, :youtube_id, :unique => true
  end
end
