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

	# not in use, since done on the frontend with jQuery 
	def parse_available_feeds_from_url(top_level_domain,search_term)
		GoogleAjax.referrer = "localhost:3000/"
		retry_count = 0
		begin
			# FIXME validate top level domain
			GoogleAjax::Feed.find("site:#{top_level_domain} #{search_term}")
			#extract unique feeds from hash
		rescue "api call error"
			#repeat or something
			Rails.logger.debug"api call failure: GoogleAjax::Feed.find"
			retry_count++
			sleep(1)
			retry unless (retry_count > 2)
		end

	end

end
