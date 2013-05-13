class AddYoutubeUrlColumnToTracksTable < ActiveRecord::Migration
  def change
    add_column :tracks, :youtube_url, :string
  end
end
