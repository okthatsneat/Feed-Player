require 'pry'
class SoundcloudProvider
	
	SOUNDCLOUD_CLIENT_ID     = "902d3c2d6d4c5c5f1dc5bee41cb01e2b"
	SOUNDCLOUD_CLIENT_SECRET = "65315148695ebb66eb6f1035dbff5c81"
	
	# only returns a soundcloud set or track if its title matches the entire request argument
	def self.query(searchTerm)
		client = Soundcloud.new(:client_id => SOUNDCLOUD_CLIENT_ID)
		#this throws 503 service unavailable sometimes, need to retry, wrap in proc
		retry_count = 0
		api_call = Proc.new do 
			#query for playlists and tracks
			playlists = client.get('/playlists', :q => searchTerm, :filter => 'streamable')
			tracks = client.get('/tracks', :q => searchTerm, :filter => 'streamable')
			results = [] << playlists << tracks      
			# loop through results
			results.each do |result|
				unless (result.empty?)
					#verify and return best result
					result.each do |item|
						(searchTerm.split(' ')).each do |search_word|
							unless (item.title =~ /#{search_word}/i)
								Rails.logger.debug"search word that broke the checking loop is #{search_word}" 
								break
							end
							#found a matching item              
							return item
						end
					end  
				end
			end
			#didn't find a result
			false        
		end  
		# retry 
		begin
			Rails.logger.debug"in query soundcloud begin block"
			api_call.call(searchTerm)
		rescue Soundcloud::ResponseError => e
			retry_count++
			#Rails.logger.debug "in rescue block soundcloud 503 response error at retry #{retry_count}"
			sleep(1)      
			retry unless (retry_count > 2)      
		end
	end

	#FIXME refactor - version of query that doesn't filter out anything and just returns the results array
	def self.query_and_return_raw(searchTerm)
	  client = Soundcloud.new(:client_id => SOUNDCLOUD_CLIENT_ID)
	  #this throws 503 service unavailable sometimes, need to retry, wrap in proc
	  retry_count = 0
	  api_call = Proc.new do 
	    #query for playlists and tracks
	    playlists = client.get('/playlists', :q => searchTerm, :filter => 'streamable')
	    tracks = client.get('/tracks', :q => searchTerm, :filter => 'streamable')
	    results = [] << playlists << tracks
	  end  
	  begin
	    Rails.logger.debug"in query soundcloud begin block"
	    api_call.call(searchTerm)
	  rescue Soundcloud::ResponseError => e
	 	  # retry 
	    retry_count++
	    sleep(1)      
	    retry unless (retry_count > 2)      
	  end
	end
	


	def self.get_embed_html5(soundcloud_uri)
		"<iframe width=\"100%\" height=\"166\" scrolling=\"no\" frameborder=\"no\" src=\"http://w.soundcloud.com/player/?url=#{URI.encode(soundcloud_uri)}&show_artwork=true&client_id=902d3c2d6d4c5c5f1dc5bee41cb01e2b\"></iframe>"
	end

	#<iframe width="100%" height="166" scrolling="no" frameborder="no" 
	#src="http://w.soundcloud.com/player/?url=http%3A%2F%2Fapi.soundcloud.com%2Ftracks%2F75968859&show_artwork=true&client_id=902d3c2d6d4c5c5f1dc5bee41cb01e2b">
	#</iframe>

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
