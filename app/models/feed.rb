class Feed < ActiveRecord::Base
  attr_accessible :etag, :feed_url, :last_modified, :title, :url
  has_many :posts

	def update_from_feed(feedzirra_feed)
  	# FIXME exists? is a class, not an instance method. 
  	unless Feed.exists? :url => feedzirra_feed.url 
    	#this also saves it to the db with validations
    	self.update_attributes(
		    :title          => feedzirra_feed.title,
		    :url            => feedzirra_feed.url,
		    :etag           => feedzirra_feed.etag,       
		    :last_modified  => feedzirra_feed.last_modified
		  )
		else
			false
		end
	end

end
