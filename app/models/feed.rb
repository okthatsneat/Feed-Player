class Feed < ActiveRecord::Base
  attr_accessible :etag, :feed_url, :last_modified, :title, :url, :top_level_domain
  has_many :posts , :dependent => :destroy
  has_and_belongs_to_many :playlists
	accepts_nested_attributes_for :playlists

  
	def update_from_feed(feedzirra_feed)
  	#this also saves it to the db with validations
  	self.update_attributes(
	    :title          => feedzirra_feed.title,
	    :url            => feedzirra_feed.url,
	    :etag           => feedzirra_feed.etag,       
	    :last_modified  => feedzirra_feed.last_modified,
	    :top_level_domain => 
	    (feedzirra_feed.url.match /(https?:\/\/www\.|https?:\/\/)(.[^\/]*)/).captures[1]
	  )
	end
end
