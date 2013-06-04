#require 'discogs'
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
    artist = CGI.escape(artist)
    begin
      #discogs api has rate limit of 1 request per second
      #sleep(1)
      _artist = @wrapper.get_artist(artist)
      #Rails.logger.debug"in list_titles_by_artist of discogs, discogs artist object is #{_artist}"    
      if _artist.releases.nil?
        return []
      end 
      _artist.releases.each do |release|
        if (release.role == "Main")
          titles << release.title
        end
      end  
      return titles    
    rescue Discogs::UnknownResource 
      return []
    end  
  end

  def artist_release_combination?(query_string, echonest_artist_object)
  query_string.downcase!    
    list_titles_by_artist(echonest_artist_object['name']).each do |title|
      if ( query_string.include?(title.downcase) && query_string.include?(echonest_artist_object['name'].downcase) )
        return true
      end
    end      
    return false
  end

end
