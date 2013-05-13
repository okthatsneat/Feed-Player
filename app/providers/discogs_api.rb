require 'discogs'
class DiscogsApi
	def initialize
		@wrapper = Discogs::Wrapper.new("Filter Player")
	end

	def list_titles_by_artist(artist)
		titles = []
		artist = URI.encode(artist)
		begin
			_artist = @wrapper.get_artist(artist)		
			_artist.releases.each do |release|
				titles << release.title
			end	
			return titles
		rescue Discogs::UnknownResource 
			return []
		end
	end
end
