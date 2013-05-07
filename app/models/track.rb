class Track < ActiveRecord::Base
  attr_accessible :name, :soundcould_uri, :soundcloud_url, :spotify_uri, :title
  has_many :keyword_tracks , :dependent => :destroy
  has_many :keywords, :through => :keyword_tracks
end
