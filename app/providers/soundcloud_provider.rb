require 'pry'
class SoundcloudProvider
  
  SOUNDCLOUD_CLIENT_ID     = "902d3c2d6d4c5c5f1dc5bee41cb01e2b"
  SOUNDCLOUD_CLIENT_SECRET = "65315148695ebb66eb6f1035dbff5c81"
	
	def self.query_soundcloud(searchTerm)
		client = Soundcloud.new(:client_id => SOUNDCLOUD_CLIENT_ID)
		#this throws 503 service unavailable sometimes, need to retry
		api_call = Proc.new{ |searchTerm|
			tracks = client.get('/tracks', :q => searchTerm, :filter => 'streamable')
		}
		begin
			api_call.call(searchTerm)
		rescue Soundcloud::ResponseError => e
			#binding.pry
			if e.response.message == "Service Unavailable"
				#retry request
				t = ThreadedApiCall.new({}, api_call(searchTerm))
				# if the main thread needs to wait for this, call 
				#t.join
				#t.result
			end
		end
	end

	def self.get_embed_html5(soundcloud_uri)
		"<iframe width=\"100%\" height=\"166\" scrolling=\"no\" frameborder=\"no\" src=\"http://w.soundcloud.com/player/?url=#{URI.encode(soundcloud_uri)}&show_artwork=true&client_id=902d3c2d6d4c5c5f1dc5bee41cb01e2b\"></iframe>"
	end

	#<iframe width="100%" height="166" scrolling="no" frameborder="no" 
	#src="http://w.soundcloud.com/player/?url=http%3A%2F%2Fapi.soundcloud.com%2Ftracks%2F75968859&show_artwork=true&client_id=902d3c2d6d4c5c5f1dc5bee41cb01e2b">
	#</iframe>


	def self.query_for_single_track_from_title(title)
		# strategy: directly query soundcloud with full title
		# if only one track comes back 
		# assume direct match
		response = query_soundcloud(title)
		if response.length == 1
			soundcloud_track = response[0]
		else 
			FALSE
		end
	end

	def self.query_for_first_track(searchTerm)
		#strategy - return the first result, use this
		#when search term is in form artist-title
		response = query_soundcloud(searchTerm)
		soundcloud_track = response[0]
	end


	def self.resolve_uri_to_track(soundcloud_uri)
		if soundcloud_uri
			client = Soundcloud.new(:client_id => SOUNDCLOUD_CLIENT_ID)
			Rails.logger.debug """
			<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

			in resolve_uri_to_track: passed in param soundcloud_uri is
			#{soundcloud_uri}

			>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
			"""
			soundcloud_track = client.get("http://#{soundcloud_uri}", :filter => 'streamable')
		end
	end


end
