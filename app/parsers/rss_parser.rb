# encoding: UTF-8
require 'pry'
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
					next if extract_tracks_from_embeds 
					artist_names = echonest_extract_artists_from_titles
					validate_and_create_tracks_semantically(artist_names)								
				end # end loop through posts				
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
			unless (create_tracks_from_player_urls(player_urls))
				# have to head over to the website to check for embeded content
				# all player_urls were not supported yet
				return create_tracks_from_embeds_on_website_behind_post				
			else
				return true
			end	
		else
			# no player_urls where found in neither summary nor body, so head over to the 
			# website to check for embeded content
			return create_tracks_from_embeds_on_website_behind_post
		end
		return false		
	end

	def validate_and_create_tracks_semantically(artist_names)
		unless (artist_names.empty?)
			artist_names.each do |artist_name|						 
				titles_found = look_for_discogs_artist_titles_in_post_title(artist_name)						
				unless (titles_found.empty?)
					titles_found.each do |title|
						if (artist_name == title) 
							# break if not present in post.title twice!
							if ( (@post.title.match /#{title}/i).captures.length < 2	)
								break
							end 
						end
						#query provider
						query = artist_name + " " + title.gsub("#{artist_name}", "")
						soundcloud_track = SoundcloudProvider.query(query)
						#ceate track
						if (soundcloud_track)
							Rails.logger.debug"query for track created is #{query}"
							Track.create_from_soundcloud_track(soundcloud_track, @post)
							Rails.logger.debug"track is #{soundcloud_track.title}"
						end			
					end
					#set up keyword for this validated artist
					KeywordPost.create_keyword_with_post!(artist_name, @post.id)							
				else 
					if (search_term_present_in_body_or_summary?(artist_name) || Keyword.exists?(:value => artist_name))
						# TODO case only artist present ------------------------------------------------
						# query for latest, most popular track?
					end
				end
			end
		end
		#	case no artists detected -----------------------------------------------
		# TODO case Various Artists release not detected by Echonest 					
		# TODO case only release title may be present in @post.title 
			# echonest extract artist on @post.summary 
			# discogs check for titles of those artists in @post.title	
	end


	def query_soundcloud_direct_with_post_title		
		soundcloud_track = 
		SoundcloudProvider.query(@post.title)
		if soundcloud_track
			#create track with parent post
			Track.create_from_soundcloud_track(soundcloud_track, @post)
		end
	end

	def look_for_discogs_artist_titles_in_post_title(artist_name)
		d = DiscogsApi.new		
		#pull list of discogs releases-titles for each keyword (=artist, found
		#by echonest)
		titles = d.list_titles_by_artist(artist_name)
		titles_found = []
		titles.each do |title|
			if (@post.title.downcase.include?(title.downcase))
				#check for self-titled releases
				titles_found << title
			end		
		end
		titles_found						
	end

	private

	def create_tracks_from_embeds_on_website_behind_post
		player_urls = HtmlParser.new(
			HTTParty.get(@post.url)).extract_player_urls_from_iframes
		unless (player_urls.empty?)
			return create_tracks_from_player_urls(player_urls)
		end
		return false
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
					return true							
				when "Youtube"
					vid_id = (player_url.match @re_youtube).captures[4] 
					if (youtube_vid = Youtube.oembed(vid_id)) 
						Track.create_from_youtube_vid(vid_id, youtube_vid, @post)
						return true
					end					
				else
					return false								
			end
		end
	end

	# returns array of artists found in @post.title
	def echonest_extract_artists_from_titles
		#construct the API call. 
		base_uri = 'http://developer.echonest.com/api/v4'
		api_type = 'artist'
		api_method = 'extract'
		api_key = 'ZHRJX1PLWUWJZRIL8'
		#grab artist related press 
		buckets = '&bucket=news&bucket=blogs&bucket=reviews&bucket=songs'
		api_request_url = Proc.new{|text| base_uri + '/' + api_type + '/' + api_method + '?' + 'api_key='+ api_key + '&format=json' + "&text=#{text}" + '&results=10' + buckets}
		text = CGI.escape(@post.title)
		# wrap api call related code in block for retry		
		api_call = Proc.new do
			response = HTTParty.get(api_request_url.call(text))		
		 	if (response['response']['status']['code'] != 0)
		 		Rails.logger.debug"failed api call response is #{response['response'].to_yaml}"
		 		raise "failed api call"		 		
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
			t = ThreadedApiCall.new({
				:name => "echonest artist extract api call", 
				:max_attempts  => 3 }, &api_call)
			t.join
			t.result
		end							
	end

	def search_term_present_in_body_or_summary?(search_term)
		(@post.summary =~ /#{search_term}/i) || (@post.body =~ /#{search_term}/i)
	end

	# cool idea, unfortunately echnonest doesn't have enough press 
	# of offer to make this work
	def validate_echonest_artist_with_echonest_outlets(artist)
		#query artist related blogs,reviews,news found by echnonest 
		#for occurence in filter source history. 
		urls = []
		blogs = artist['blogs'] 
		news = artist['news']
		reviews = artist['reviews']
		outlets = [] << blogs << news << reviews		
		outlets.each do |outlet|
			if (outlet)
				outlet.each do |outlet|
					url = outlet['url']
					if (url =~ /#{@feed.top_level_domain}/)						
						return true
					end
				end
			end
		end		
	# if it reaches this point, there was no match
	return false		
	end
	
	def present_in_post_summary?(artist_name)
		@post.summary.include?(artist_name)
	end

	def regex_titles_for_keywords
		# matches the word before and after common artist - title delimiters
		# like “:”, “-“, or “–“
		re1 = /(\w+\s?(?:–|:|-)\s?\w+)/
		# match groups of captitalized words, optionally delimited with , or "" 
		re2 = /([A-Z]'?\w+,?(?:\s"?[A-Z]'?\w+,?"?)+)/
		regexes = [] << re1 << re2
		# dump all matches as keywords		
		regexes.each do | re |
			match = @post.title.match re
			if match
				match.captures.each do | capture |
				KeywordPost.create_keyword_with_post!(capture, @post.id)
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
