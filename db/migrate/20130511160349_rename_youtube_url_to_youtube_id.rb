class RenameYoutubeUrlToYoutubeId < ActiveRecord::Migration
  def change
  	rename_column :tracks, :youtube_url, :youtube_id
  end

end
