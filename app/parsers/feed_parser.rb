# require discogs before starting PostWorker for thread saftey
require 'discogs'

class FeedParser
  def initialize(feed)
    @feed = feed
    @feed_url = feed.feed_url    
  end

  def parse
    Rails.logger.debug"in FeedParser::parse"
    #fetch and parse feed with Feezirra
    feedzirra_feed = Feedzirra::Feed.fetch_and_parse(@feed_url)
    Rails.logger.debug"after fetch_and_parse, feedzirra_feed is #{feedzirra_feed}"
 
    # if this fails feedzirra_feed is the Fixnum error code, not the feed object
    unless feedzirra_feed.is_a?(Fixnum)
      #if !exists, set attributes and save to db
      if @feed.update_from_feed(feedzirra_feed)
        Rails.logger.debug"inside if update_from_feed(feedzirra_feed) - @feed is #{@feed}"
        #create! posts if !exists, set attributes from RSS feed
        Post.update_from_feed(feedzirra_feed, @feed.id)
        @feed.posts.each do |post|
          post_parser = PostParser.new(post.id)          
          return if post_parser.extract_tracks_from_embeds
          #artist_names = EchonestApi.extract_artists_from_titles(post.id)
          #post_parser.validate_and_create_tracks_semantically(artist_names)
          #PostWorker.perform_async(post.id)
          #Rails.logger.debug"called post worker for post #{post.title} of feed #{post.feed.title}"
          (EchonestApi.extract_artist_objects_from_title(post.id)).each do |echonest_artist|
            post_parser.validate_and_create_tracks_after_provider_request(echonest_artist)
          end                    
        end # end loop through posts        
      end
      @feed
    else
      FALSE
    end
  end
end
