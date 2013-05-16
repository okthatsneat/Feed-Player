require 'pry'
require 'httparty'

# temp script to test echonest api
base_uri = 'http://developer.echonest.com/api/v4'
api_type = 'artist'
api_method = 'extract'
api_key = 'ZHRJX1PLWUWJZRIL8'
#grab artist related press needed for validation 
buckets = '&bucket=news&bucket=blogs&bucket=reviews&bucket=songs'
api_call = Proc.new{|text| base_uri + '/' + api_type + '/' + api_method + '?' + 'api_key='+ api_key + '&format=json' + "&text=#{text}" + '&results=10' + buckets}
text = "John Tejada - Sweat On The Walls Proxy Celeste"
binding.pry
response = HTTParty.get(api_call.call(text))
response["response"]["artists"].each do |artist|
	#validate the artist found
	#collect all urls from reviews, news, blog posts
	urls = []
	artist['name']['blogs'].each do |blog|
		urls << blog['url']
	end
	artist['name']['news'].each do |news_item|
		urls << news_item['url']
	end
	artist['name']['reviews'].each do |review|
		urls << review['url']
	end

	urls.each do |url|
		if (url =~ /#{@feed.top_level_domain}/)
			true
		else
			false
		end
	end

	end

	# regex the filter source from the url, compare with feed url
	# get top level domain from current feed
	artist['name']['news']['url']
	artist['name']['reviews']['url']
#	if (validate_artist(artist))
		#set up keyword for each returned artist name
#		KeywordPost.create_keyword_with_post!(artist["name"], @post.id)

#	end
end