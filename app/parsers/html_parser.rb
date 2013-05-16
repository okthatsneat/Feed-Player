class HtmlParser

	def initialize(html_document)
		@doc = Nokogiri::HTML(html_document)
	end

	def extract_player_urls_from_iframes
		# parse html in posts bodies with nokogiri
		player_urls = []
		#find all iframes, decode their player_url = src value to regexable string, 
		#store post with player player_url 
		@doc.xpath("//iframe").each do |iframe|
			player_urls << URI.decode(iframe.attributes['src'].value)
		end
		return player_urls		
	end

	def extract_links
		#TODO
	end


end
