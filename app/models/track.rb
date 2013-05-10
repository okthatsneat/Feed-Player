class Track < ActiveRecord::Base
  attr_accessible :name, :soundcloud_uri, :soundcloud_url, :soundcloud_embed, 
  	:spotify_uri, :title
  has_many :keyword_tracks , :dependent => :destroy
  has_many :keywords, :through => :keyword_tracks
  has_and_belongs_to_many :posts

  def pull_soundcloud_embed
	  self.soundcloud_embed = SoundcloudProvider.get_embed_html5(self.soundcloud_uri)
	  self.save
  end

  def self.create_from_soundcloud_track(soundcloud_track, post)
		if Track.exists? :soundcloud_uri => soundcloud_track.uri
			Track.find_by_soundcloud_uri(soundcloud_track.uri).posts << post
		else
			post.tracks.create	do |track| 
				track.title 						=	soundcloud_track.title,
				track.soundcloud_uri		=	soundcloud_track.uri,
				track.soundcloud_url 		= 
				(soundcloud_track.user.permalink_url + '/' + soundcloud_track.permalink)
			end 
		end
	end
	




end
