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

end
