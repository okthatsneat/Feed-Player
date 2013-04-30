# encoding: UTF-8
class RSSParser

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
				regex_titles_for_keywords
			end
			@feed
		else 
			false
		end
	end

	private

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
						# create a new Keyword with the capture
						# FIXME check for duplicates
						keyword = Keyword.create!(value: capture)
						# create a new keyword_posts entry
						# insert the keyword's id
						post.keyword_posts.create!(keyword_id: keyword.id)
					end
				end
			end
		end
	end
	


end
