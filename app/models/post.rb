class Post < ActiveRecord::Base
	attr_accessible :title, :body, :summary,
	 :url, :published_at, :guid, :feed_id, :keywords_posts_attributes
	has_many :keyword_posts , :dependent => :destroy
	has_many :keywords, :through => :keyword_posts
	has_and_belongs_to_many :tracks


	accepts_nested_attributes_for :keyword_posts, :allow_destroy => true

	belongs_to :feed

	#from http://railscasts.com/episodes/168-feed-parsing?view=asciicast
	def self.update_from_feed(feedzirra_feed, parent_feed_id)
		feedzirra_feed.entries.each do |entry|
	    unless exists? :guid => entry.id
	      create!(
	        :title        => entry.title,
	        :summary      => entry.summary,
	        :url          => entry.url,
	        :published_at => entry.published,
	        :guid         => entry.id,
	        :feed_id	    => parent_feed_id
	      )
	    end
	  end
	end

	def create_track_from_title
		# strategy: directly query soundcloud with full title
		# if only one track comes back 
		# assume direct match
		response = SoundcloudProvider.query_soundcloud(self.title)
				
		if response.length == 1
			soundcloud_track = response[0]
			uri = soundcloud_track.uri
			#embed = SoundcloudProvider.get_embed_html5(uri) - too slow
			unless Track.exists? :soundcloud_uri => uri
				self.tracks.create	do |track| 
					#track.soundcloud_embed	= embed,
					track.title 						=	soundcloud_track.title,
					track.soundcloud_uri		=	uri,
					track.soundcloud_url 		= 
					(soundcloud_track.user.permalink_url + '/' + soundcloud_track.permalink)
				end
			end
		end
	end
end
