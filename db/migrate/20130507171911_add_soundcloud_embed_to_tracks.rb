class AddSoundcloudEmbedToTracks < ActiveRecord::Migration
  def change
    add_column :tracks, :soundcloud_embed, :text
  end
end
