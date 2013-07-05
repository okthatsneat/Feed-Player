class Playlist < ActiveRecord::Base
  has_one :playlist_track, :dependent => :destroy
  has_many :tracks, :through => :playlist_track
  has_and_belongs_to_many :feeds, :after_add => :update_playlist_track_with_feed
  attr_accessible :title, :description, :feeds_attributes
  accepts_nested_attributes_for :feeds

  def feeds_attributes=(hash)
  	Rails.logger.debug"hash passed to create feeds is #{hash.to_yaml}"
    hash.each do |sequence,feed_values|
      feeds <<  Feed.find_or_create_by_feed_url(feed_values[:feed_url])
    end
  end

	private

	def update_playlist_track_with_feed(feed)
		Rails.logger.debug"update_playlist_track_with_feed callback triggered!"
		#pull all related feeds, their already parsed posts, their already existing tracks and relate them to 
		# this playlist. 
		# this is also where filters will go that kick tracks out of playlists by user constraints.
		feed.posts.collect(&:tracks).flatten.each do |track|
			# FIXME unless self.tracks => track already exists
			PlaylistTrack.create(playlist:self, track:track)

		end 
	end

end
