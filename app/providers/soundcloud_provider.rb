class SoundcloudProvider
  
  SOUNDCLOUD_CLIENT_ID     = "902d3c2d6d4c5c5f1dc5bee41cb01e2b"
  SOUNDCLOUD_CLIENT_SECRET = "65315148695ebb66eb6f1035dbff5c81"
	
	def self.query_soundcloud(searchTerm)
		client = Soundcloud.new(:client_id => SOUNDCLOUD_CLIENT_ID)
		tracks = client.get('/tracks', :q => searchTerm, :filter => 'streamable')
	end

	def self.get_embed_html5(soundcloud_url)
		client = Soundcloud.new(:client_id => SOUNDCLOUD_CLIENT_ID)
		embed_info = client.get('/oembed', :url => soundcloud_url)
		embed_info['html']
	end

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

	def self.resolve_uri_to_track(soundcloud_uri)
		if soundcloud_uri
			client = Soundcloud.new(:client_id => SOUNDCLOUD_CLIENT_ID)
			Rails.logger.debug """
			<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

			in resolve_uri_to_track: passed in param soundcloud_uri is
			#{soundcloud_uri}

			>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
			"""

			soundcloud_track = client.get("http://#{soundcloud_uri}")
		end
	end


end
