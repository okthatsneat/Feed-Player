class Track < ActiveRecord::Base
  attr_accessible :name, :soundcould_uri, :soundcloud_url, :spotify_uri, :title
end
