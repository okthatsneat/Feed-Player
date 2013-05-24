# encoding: UTF-8
require 'pry'
class RSSParser


	

	



	

	

	#private

	
	


	

	# FIXME this won't work with the new paralel design (update code if revive)
	# cool idea, unfortunately echnonest doesn't have enough press 
	# of offer to make this work
	# def validate_echonest_artist_with_echonest_outlets(artist)
	# 	#query artist related blogs,reviews,news found by echnonest 
	# 	#for occurence in filter source history. 
	# 	urls = []
	# 	blogs = artist['blogs'] 
	# 	news = artist['news']
	# 	reviews = artist['reviews']
	# 	outlets = [] << blogs << news << reviews		
	# 	outlets.each do |outlet|
	# 		if (outlet)
	# 			outlet.each do |outlet|
	# 				url = outlet['url']
	# 				if (url =~ /#{@feed.top_level_domain}/)						
	# 					return true
	# 				end
	# 			end
	# 		end
	# 	end		
	# # if it reaches this point, there was no match
	# return false		
	# end
	
	
	# not in use currently
	# def regex_titles_for_keywords
	# 	# matches the word before and after common artist - title delimiters
	# 	# like “:”, “-“, or “–“
	# 	re1 = /(\w+\s?(?:–|:|-)\s?\w+)/
	# 	# match groups of captitalized words, optionally delimited with , or "" 
	# 	re2 = /([A-Z]'?\w+,?(?:\s"?[A-Z]'?\w+,?"?)+)/
	# 	regexes = [] << re1 << re2
	# 	# dump all matches as keywords		
	# 	regexes.each do | re |
	# 		match = @post.title.match re
	# 		if match
	# 			match.captures.each do | capture |
	# 			KeywordPost.create_keyword_with_post!(capture, @post.id)
	# 			end
	# 		end
	# 	end		
	# end	

	
end
