# require discogs before starting PostWorker for thread saftey
require 'discogs'

class FeedParser
  def initialize(feed)
    @feed = feed
    @feed_url = feed.feed_url    
  end

  def parse
    #fetch and parse feed with Feezirra
    feedzirra_feed = Feedzirra::Feed.fetch_and_parse(@feed_url)
    # if this fails feedzirra_feed is the Fixnum error code, not the feed object
    unless feedzirra_feed.is_a?(Fixnum)
      #if !exists, set attributes and save to db
      if @feed.update_from_feed(feedzirra_feed)
        #create! posts if !exists, set attributes from RSS feed
        new_feed_entries = Post.update_from_feed(feedzirra_feed, @feed.id)
        new_feed_entries.each do |post|          
          PostWorker.perform_async(post.id)            
        end # end loop through posts        
      end
      @feed
    else
      FALSE
    end
  end
end
