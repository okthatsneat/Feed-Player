require 'discogs'
class DiscogsApi
	
	def initialize
		@wrapper = Discogs::Wrapper.new("Filter Player")
		@bad_request_strings = ["Various"]
	end

	def list_titles_by_artist(artist)
		titles = []
		@bad_request_strings.each do |string|
			if string.eql?(artist)
				return []
			end
		end
		artist = URI.encode(artist)
		begin
			Rails.logger.debug"in list_titles_by_artist of discogs, artist is #{artist}"
			_artist = @wrapper.get_artist(artist)
			Rails.logger.debug"in list_titles_by_artist of discogs, discogs artist object is #{_artist}"		
			_artist.releases.each do |release|
				titles << release.title
			end	
			return titles		
		rescue Discogs::UnknownResource 
			return []
		end	
	end
end
