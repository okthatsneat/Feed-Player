class PostWorker
  include Sidekiq::Worker
  
  def perform(post_id)
		# get the embeded content and create tracks   
		post_parser = PostParser.new(post_id)					
		return if post_parser.extract_tracks_from_embeds
		artist_names = Echonest.extract_artists_from_titles(post_id)
		post_parser.validate_and_create_tracks_semantically(artist_names)
	end
end