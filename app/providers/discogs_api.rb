#require 'discogs'
class DiscogsApi
  
  def initialize
    @wrapper = Discogs::Wrapper.new("Feed Player")
    @bad_request_strings = ["Various"]
  end

  def list_titles_by_artist(artist)
    titles = []
    # the value "Various" is not an allowed parameter to the get_artist API call. No Documentation found. 
    @bad_request_strings.each do |string|
      if string.eql?(artist)
        return []
      end
    end
    api_call = Proc.new do 
      _artist = @wrapper.get_artist(artist)
      #Rails.logger.debug"in list_titles_by_artist of discogs, discogs artist object is #{_artist}"    
      if _artist.releases.nil?
        return []
      end 
      _artist.releases.each do |release|
        if (release.role == "Main")
          titles << {:release_id =>release.id, :release_title => release.title}                    
        end
      end  
      return titles
    end
    rescued_api_call(api_call)    
  end

  def list_songs_by_releases(titles)
    songs=[]
    titles.each do |title|
      api_call = Proc.new do 
        release = @wrapper.get_release(title[:release_id])
        release.tracklist.each do |track|
          songs << track.title
        end
      end
      rescued_api_call(api_call)
    end
    unless songs.empty?
      return songs
    else
      Rails.logger.debug"returning false from discogs - unless songs.empty?"
      return false
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

  def rescued_api_call(api_call)
    begin     
      api_call.call
    rescue Discogs::UnknownResource 
      return []
    rescue Errno::ETIMEDOUT       
      # rescue Discogs error stemming from too many calls per second.
      # discogs api has rate limit of 1 request per second (actually 60 per minute)
      # so let this thread sleep if requests start to fail.
      sleep(30)
      retry
    rescue URI::InvalidURIError
      return []
    end  
  end


end
