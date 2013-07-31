class Playlist < ActiveRecord::Base
  before_destroy :clean_up_unreferenced_feeds
  has_one :playlist_track, :dependent => :destroy
  has_many :tracks, :through => :playlist_track
  has_and_belongs_to_many :feeds, :after_add => :update_playlist_track_with_feed
  attr_accessible :title, :description, :feeds_attributes
  accepts_nested_attributes_for :feeds

  def feeds_attributes=(hash)
    hash.each do |sequence,feed_values|
      feeds <<  Feed.find_or_create_by_feed_url(feed_values[:feed_url])
    end
  end

	private

	def update_playlist_track_with_feed(feed)
		# pull the added feed's tracks through their posts and relate them to this playlist. 
		# this is also where filters will go that kick tracks out of playlists by user constraints.
		feed.posts.collect(&:tracks).flatten.each do |track|
			PlaylistTrack.create(playlist:self, track:track) unless self.tracks.exists?(track.id)
		end 
	end

  def clean_up_unreferenced_feeds
    self.feeds.each do |feed|
      feed.destroy unless feed.playlists.any?
    end
  end


end
