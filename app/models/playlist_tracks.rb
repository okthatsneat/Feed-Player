class PlaylistTracks < ActiveRecord::Base
	belongs_to :playlist
	belongs_to :track
	attr_accessible :position
end
