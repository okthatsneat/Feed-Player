class AddYoutubeEmbedColumnToTracks < ActiveRecord::Migration
  def change
    add_column :tracks, :youtube_embed, :string
  end
end
