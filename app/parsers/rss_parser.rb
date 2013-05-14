# encoding: UTF-8
class RSSParser
	include HTTParty
  format :json

	def initialize(feed)
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
				#create! posts if !exists, set attributes from RSS feed
				Post.update_from_feed(feedzirra_feed, @feed.id)
				@feed.posts.each do |post|
					@post = post
					extract_tracks_from_embeds
					#regex_titles_for_keywords - replaced by Echonest API call
					#echonest_extract_artists_from_titles
					#look_for_artist_titles_in_post_title
					#query_soundcloud_direct_with_post_title	
				end				
			end
			@feed
		else 
			FALSE
		end
	end

	def extract_tracks_from_embeds
		#strategy: first extract from body and summary feed fields. if none present
		#head over to the post.url and check there. 

				
		player_urls = []
		player_urls = HtmlParser.new(@post.summary).extract_player_urls_from_iframes
		player_urls.concat(HtmlParser.new(@post.body).extract_player_urls_from_iframes)
		
		unless player_urls.empty?
			if ("None" == (create_tracks_from_player_urls(player_urls)))
				# have to head over to the website to check for embeded content
				# all player_urls were bullshit or not supported yet
				create_tracks_from_embeds_on_website_behind_post				
			end	
		else
			# no player_urls where found in neither summary nor body, so head over to the 
			# website to check for embeded content
			create_tracks_from_embeds_on_website_behind_post
		end		
	end

	def query_soundcloud_direct_with_post_title
		@feed.posts.each do | post |
		  soundcloud_track = 
	    SoundcloudProvider.query_for_single_track_from_title(post.title)
	    if soundcloud_track
	      #create track with parent post
	      Track.create_from_soundcloud_track(soundcloud_track, post)
	    end	    
    end 
	end

	def look_for_artist_titles_in_post_title
		d = DiscogsApi.new
		@feed.posts.each do |post|
			post.keywords.each do |keyword|
				#pull list of discogs releases-titles for each keyword (=artist, found
				#by echonest)
				titles = d.list_titles_by_artist(keyword.value)
				titles.each do |title|
					if (post.title.downcase.include?(title.downcase))
						#create a track if single result found
						if (soundcloud_track =
						SoundcloudProvider.query_for_first_track(
							keyword.value + " " + title))
							Track.create_from_soundcloud_track(soundcloud_track, post)
						end
					end
				end
			end
		end
	end

	def self.update_embeds(post)
		post.tracks.each do |track|
	  	unless track.soundcloud_embed
	    	track.pull_soundcloud_embed
	  	end
	  end
	end

	private

	def create_tracks_from_embeds_on_website_behind_post
		player_urls = HtmlParser.new(
			HTTParty.get(@post.url)).extract_player_urls_from_iframes
		unless (player_urls.empty?)
			create_tracks_from_player_urls(player_urls)
		end
	end

	def create_tracks_from_player_urls(player_urls)
		@re_soundcloud = /(api\.soundcloud\.com[^&]*)/
		# credit https://gist.github.com/afeld/1254889 for regex 
		@re_youtube = /(youtu\.be\/|youtube\.com\/(watch\?(.*&)?v=|(embed|v)\/))([^\?&"'>]+)/

		player_urls.each do |player_url|
			player_type = identify_player_type(player_url)
			case player_type
				when "Soundcloud"
					#resolve soundcloud uri to track
					soundcloud_uri = (player_url.match @re_soundcloud).captures[0] 
					soundcloud_track = SoundcloudProvider.resolve_uri_to_track(soundcloud_uri)
					Track.create_from_soundcloud_track(soundcloud_track, @post)							
				when "Youtube"
					# resolve via oembed, call track method to create with youtube info
					# @match.captures[4] = $5 is the vid id in this case
					Rails.logger.debug"""
					
					player_url is #{player_url}					
					@re_youtube is #{@re_youtube}
					player_url.mactch @re_youtube is#{player_url.match @re_youtube}

					"""

					vid_id = (player_url.match @re_youtube).captures[4] 
					if (youtube_vid = Youtube.oembed(vid_id)) 
						Track.create_from_youtube_vid(vid_id, youtube_vid, @post)
					end
			else return "None"								
			end
		end
	end

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

	def identify_player_type(player_url)
		# switch depending on type
		if (player_url =~ @re_soundcloud)
			return "Soundcloud"
		elsif (player_url =~ @re_youtube)
			return "Youtube"
		else
			 return "None"
		end
	end
end
