class Track < ActiveRecord::Base
  
  attr_accessible :name, :soundcloud_uri, :soundcloud_url, :soundcloud_embed, 
    :spotify_uri, :title
  
  has_many :keyword_tracks , :dependent => :destroy
  has_many :keywords, :through => :keyword_tracks
  has_and_belongs_to_many :posts, :after_add => :update_playlists
  has_many :playlist_tracks, :dependent => :destroy
  has_many :playlists, :through => :playlist_tracks

  def self.create_from_soundcloud_track(soundcloud_track, post)
    if Track.exists? :soundcloud_uri => soundcloud_track.uri
      if post.tracks.find_by_soundcloud_uri(soundcloud_track.uri)
        # do nothing
      else
        Track.find_by_soundcloud_uri(soundcloud_track.uri).posts << post       
      end
    else
      post.tracks.create  do |track| 
        track.title             =  soundcloud_track['title']
        track.soundcloud_uri    =  soundcloud_track.uri
        track.soundcloud_url     = 
        (soundcloud_track.user.permalink_url + '/' + soundcloud_track.permalink)
        track.soundcloud_embed = SoundcloudProvider.get_embed_html5(track.soundcloud_uri)
      end       
    end
  end

  def self.create_from_youtube_vid(vid_id, youtube_vid, post)
    if Track.exists? :youtube_id => vid_id
      if post.tracks.find_by_youtube_id(vid_id)
        # do nothing        
      else
        Track.find_by_youtube_id(vid_id).posts << post        
      end
    else
      post.tracks.create do |track|
        track.title            = youtube_vid['title']
        track.youtube_id      = vid_id
        track.youtube_embed    = youtube_vid['html']
      end       
    end
  end

  private

  #save new track to all related playlists, using the post object.
  def update_playlists(post)
    Rails.logger.debug"it works!"
    # also the future place to check for user preferences that would reject the track for the playlist
    post.feed.playlists.each do |playlist|
      #FIXME shield against duplicate entries
      PlaylistTrack.create(playlist: playlist, track: self)
    end    
  end

end
