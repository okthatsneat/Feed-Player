class ChangeYoutubeEmbedTypeToText < ActiveRecord::Migration
 def self.up
  	change_column :tracks, :youtube_embed, :text
  end
end
