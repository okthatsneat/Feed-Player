# encoding: UTF-8
class RSSParser
	include HTTParty
  format :json

	def initialize (feed)
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
				#create! posts if !exists, set attributes
				Post.update_from_feed(feedzirra_feed, @feed.id)
				#regex_titles_for_keywords - replaced by Echonest API call
				#comment out to speed up testing
				#echonest_extract_artists_from_titles
			end
			@feed
		else 
			FALSE
		end
	end

	def extract_tracks_from_embeds
		re_soundcloud = /(api\.soundcloud\.com[^&]*)/
		# credit https://gist.github.com/afeld/1254889 for regex 
		re_youtube = /(youtu\.be\/|youtube\.com\/(watch\?(.*&)?v=|(embed|v)\/))([^\?&"'>]+)/
		
		extract_player_urls_from_iframes_in_posts_bodies
		
		if @player_urls
			@player_urls.each do | hash |
				player_url = hash[:player_url]
				player_type = identify_player_type(player_url)
				case player_type
				 	when "Soundcloud"
						then
							#resolve soundcloud uri to track
							soundcloud_uri = (hash[:player_url].match re_soundcloud).captures[0] 
							soundcloud_track = SoundcloudProvider.resolve_uri_to_track(soundcloud_uri)
							Track.create_from_soundcloud_track(soundcloud_track, hash[:post]) 
							
					when "Youtube"
						then
						# resolve via oembed, call track method to create with youtube info
						# @match.captures[4] = $5 is the vid id in this case
							Rails.logger.debug """

							hash value at :player_url is #{hash[:player_url]}

							re_youtube is #{re_youtube}

							"""
							vid_id = (hash[:player_url].match re_youtube).captures[4] 
							if (youtube_vid = Youtube.oembed(vid_id)) 
								Track.create_from_youtube_vid(vid_id, youtube_vid, hash[:post])
							end
				end
			end
		end
	end

	private

	def echonest_extract_artists_from_titles
		#construct the API call. 
		# ex: http://developer.echonest.com/api/v4/artist/
		# extract?api_key=ZHRJX1PLWUWJZRIL8&format=json&
		# text=Siriusmo%20is%20my%20favorite%20,%20but%20I%20also%20like%20hrvatski&results=10

		base_uri = 'http://developer.echonest.com/api/v4'
		api_type = 'artist'
		api_method = 'extract'
		api_key = 'ZHRJX1PLWUWJZRIL8'
		
		@api_call = Proc.new{|text| base_uri + '/' + api_type + '/' + api_method + '?' + 'api_key='+ api_key + '&format=json' + "&text=#{text}" + '&results=10'}

		@feed.posts.each do |post|
			text = URI::encode(post.title)
			#Rails.logger.debug "text after URI encoding is #{text}"
			response = HTTParty.get(@api_call.call(text))
			response["response"]["artists"].each do |artist|
				#set up keyword for each returned artist name
				KeywordPost.create_keyword_with_post!(artist["name"], post.id)
			end
		end
	end



	def regex_titles_for_keywords
		# matches the word before and after common artist - title delimiters
		# like “:”, “-“, or “–“
		re1 = /(\w+\s?(?:–|:|-)\s?\w+)/
		# match groups of captitalized words, optionally delimited with , or "" 
		re2 = /([A-Z]'?\w+,?(?:\s"?[A-Z]'?\w+,?"?)+)/
		regexes = [] << re1 << re2
		# dump all matches as keywords
		@feed.posts.each do | post |
			regexes.each do | re |
				match = post.title.match re
				if match
					match.captures.each do | capture |
					KeywordPost.create_keyword_with_post!(capture, post.id)
					end
				end
			end
		end
	end

	
	def extract_player_urls_from_iframes_in_posts_bodies
		# parse html in posts bodies with nokogiri
		@player_urls = []
		@feed.posts.each do |post|
			doc = Nokogiri::HTML(post.body)
			#find all iframes, decode their player_url = src value to regexable string, 
			#store post with player url 
			doc.xpath("//iframe").each do |iframe|
				@player_urls << 
				{player_url: URI.decode(iframe.attributes['src'].value), post: post}
			end
		end
	end

	def identify_player_type(player_url)
		# switch depending on type
		if (player_url.include? 'soundcloud')
			Rails.logger.debug"""

			in identify player type : player_url #{player_url}


			"""
			return "Soundcloud"
		elsif (player_url.include? 'youtube')
			return "Youtube"
		else
			 return "None"
		end
	end


			
		

	


end
