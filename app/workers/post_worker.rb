class PostWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :posts_queue, :backtrace => true
  
  def perform(post_id)
    # get the embeded content and create tracks   
    post_parser = PostParser.new(post_id)          
    return if post_parser.extract_tracks_from_embeds
    #else
    #old strategy with discogs
    artist_names = EchonestApi.extract_artists_from_titles(post_id)
    post_parser.validate_and_create_tracks_semantically(artist_names)

    #new strategy with validation after direct soundcloud response (has problems)
    #(EchonestApi.extract_artist_objects_from_title(post_id)).each do |echonest_artist|
    #  post_parser.validate_and_create_tracks_after_provider_request(echonest_artist)
    #end
  end
end