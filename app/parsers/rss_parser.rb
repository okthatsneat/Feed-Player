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

	def self.extract_tracks_from_soundcloud_embeds(post)
		# FIXME multiple calls are creating duplicate tracks in post

		# parse html in post body with nokogiri
		doc = Nokogiri::HTML(Post.find(post.id).body)
		#find all iframes, decode their src value to regexable string
		doc.xpath("//iframe").each do |iframe|
			player_url = URI.decode(iframe.attributes['src'].value)
			Rails.logger.debug """
			<<<<<<<<<<<<<<<<<<<<<<

			in extract_tracks_from_soundcloud_embeds: 
			player_url is #{player_url}


			>>>>>>>>>>>>>>>>>>>>>>>>
			"""


			#regex soundcloud uri from player_url, if present, create track
			match = player_url.match /(api\.soundcloud\.com[^&]*)/
			if match
				
			Rails.logger.debug """
			<<<<<<<<<<<<<<<<<<<<<<

			in if match , extract_tracks_from_soundcloud_embeds: 
			first capture is #{match.captures.first}

			>>>>>>>>>>>>>>>>>>>>>>>>
			"""

				#resolve soundcloud uri to souncloud track
				# FIXME multiple calls are creating duplicate tracks in post
				if (soundcloud_track = 
					SoundcloudProvider.resolve_uri_to_track(match.captures.first))
					
					Track.create_from_soundcloud_track(soundcloud_track, post) 
				end

			end
		end
		
	end

	


end
