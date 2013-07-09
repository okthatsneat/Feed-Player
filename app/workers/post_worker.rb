class PostWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :posts_queue, :backtrace => true
  
  def perform(post_id)
    # get the embeded content and create tracks   
    post_parser = PostParser.new(post_id)          
    #return if
    #post_parser.extract_tracks_from_embeds
    #else
    #return if
    #post_parser.create_tracks_for_coverart
    # else strategy with discogs validated echonest extract artists in post title    
    post_parser.validate_and_create_tracks_semantically    
  end
end