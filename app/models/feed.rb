class Feed < ActiveRecord::Base
  attr_accessible :etag, :feed_url, :last_modified, :title, :url, :top_level_domain
  has_many :posts , :dependent => :destroy

	def update_from_feed(feedzirra_feed)
  	# FIXME exists? is a class, not an instance method. 
  	unless Feed.exists? :feed_url => feedzirra_feed.feed_url 
    	#this also saves it to the db with validations
    	self.update_attributes(
		    :title          => feedzirra_feed.title,
		    :url            => feedzirra_feed.url,
		    :etag           => feedzirra_feed.etag,       
		    :last_modified  => feedzirra_feed.last_modified,
		    :top_level_domain => 
		    (feedzirra_feed.url.match /(https?:\/\/www\.|https?:\/\/)(.[^\/]*)/).captures[1]
		  )
		else
			false
		end
	end

end
