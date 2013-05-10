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
	        :body					=> entry.content,
	        :summary      => entry.summary,
	        :url          => entry.url,
	        :published_at => entry.published,
	        :guid         => entry.id,
	        :feed_id	    => parent_feed_id
	      )
	    end
	  end
	end

	
end
