class EchonestApi

	# returns array of artists found in post.title
	def self.extract_artists_from_titles(post_id)
		post = Post.find(post_id)
		#construct the API call. 
		base_uri = 'http://developer.echonest.com/api/v4'
		api_type = 'artist'
		api_method = 'extract'
		api_key = 'ZHRJX1PLWUWJZRIL8'
		#grab artist related press 
		buckets = '&bucket=news&bucket=blogs&bucket=reviews&bucket=songs'
		api_request_url = Proc.new{|text| base_uri + '/' + api_type + '/' + api_method + '?' + 'api_key='+ api_key + '&format=json' + "&text=#{text}" + '&results=10' + buckets}
		text = CGI.escape(post.title)
		# wrap api call related code in block for retry
		retry_count = 0		
		api_call = Proc.new do
			response = HTTParty.get(api_request_url.call(text))
		 	if (response['response']['status']['code'] != 0)
		 		puts"failed api call response is #{response['response'].to_yaml}"
		 		raise "failed echonest api call with response #{response['response'].to_yaml}"		 		
		 	end 
		 	artists = response['response']['artists']
		 	artist_names = []
		 	unless artists.nil?
				artists.each do |artist|
			 		artist_names << artist['name']
				end
			end
		 	return artist_names
		end
		begin			
			api_call.call
			#artists.each will throw no method error if artists is nil
		rescue RuntimeError => e
			#retry api request
			retry_count++
			#Rails.logger.debug"Echonest Api call failed, so far #{pluralize(retry_count, 'failure')}"
			sleep(1)			
			retry unless (retry_count > 2)
		end							
	end
end
