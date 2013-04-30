class Keyword < ActiveRecord::Base
	attr_accessible :value
	has_many :keyword_posts
	has_many :keyword_tracks
	has_many :posts, :through => :keyword_posts
	has_many :tracks, :through => :keyword_tracks
end

