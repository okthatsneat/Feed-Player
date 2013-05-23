class Playlist < ActiveRecord::Base
	has_one :playlist_tracks, :dependent => :destroy
	has_many :tracks, :through => :playlist_tracks
	has_and_belongs_to_many :feeds
	attr_accessible :title, :description, :feeds_attributes
	accepts_nested_attributes_for :feeds

end
