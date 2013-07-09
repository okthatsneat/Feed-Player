class Post < ActiveRecord::Base
  attr_accessible :title, :body, :summary,
   :url, :published_at, :guid, :feed_id, :keywords_posts_attributes
  has_many :keyword_posts , :dependent => :destroy
  has_many :keywords, :through => :keyword_posts
  has_and_belongs_to_many :tracks, :after_add => :update_playlists

  accepts_nested_attributes_for :keyword_posts, :allow_destroy => true

  belongs_to :feed

  #from http://railscasts.com/episodes/168-feed-parsing?view=asciicast
  def self.update_from_feed(feedzirra_feed, parent_feed_id)
    new_feed_entries = []
    feedzirra_feed.entries.each do |entry|
      unless exists? :guid => entry.id
        new_feed_entries << create!(
          :title        => entry.title,
          :body          => entry.content,
          :summary      => entry.summary,
          :url          => entry.url,
          :published_at => entry.published,
          :guid         => entry.id,
          :feed_id      => parent_feed_id
        )
      end
    end
    return new_feed_entries
  end

  private

  #save new track to all related playlists, using self.
  def update_playlists(track)
    Rails.logger.debug"it works!"
    # also the future place to check for user preferences that would reject the track for the playlist
    self.feed.playlists.each do |playlist|
      PlaylistTrack.create(playlist: playlist, track: track) unless playlist.tracks.exists?(track.id)
    end    
  end
  
end
