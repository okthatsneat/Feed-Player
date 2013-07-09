require 'pry'
class EchonestApi

  # returns array of artist names found in post.title
  def self.extract_artists_from_titles(post_id)
    artists = self.extract_artist_objects_from_title(post_id)
    artist_names = []
    unless artists.nil?
      artists.each do |artist|
        artist_names << artist['name'] unless artist['name'].eql?('a') # useless artist 'a' echonest finds all the time 
      end
      return artist_names
    else
      return false
    end      
  end

  def self.extract_artist_objects_from_title(post_id)
    post = Post.find(post_id)
    query_string = post.title
    return self.extract_artist_objects_from_string(query_string)    
  end

  def self.extract_artist_objects_from_string(query_string)
    #construct the API call. 
    base_uri = 'http://developer.echonest.com/api/v4'
    api_type = 'artist'
    api_method = 'extract'
    api_key = 'ZHRJX1PLWUWJZRIL8'
    #grab artist related press 
    buckets = '&bucket=news&bucket=blogs&bucket=reviews&bucket=songs'
    api_request_url = Proc.new{|text| base_uri + '/' + api_type + '/' + api_method + '?' + 'api_key='+ api_key + '&format=json' + "&text=#{CGI.escape(text)}" + '&results=10' + buckets}
    text = query_string
    # wrap api call related code in block for retry
    retry_count = 0    
    api_call = Proc.new do
      response = HTTParty.get(api_request_url.call(text))
      if (response['response']['status']['code'] != 0)
        puts"failed api call response is #{response['response'].to_yaml}"
        raise "failed echonest api call with response #{response['response'].to_yaml}"         
      end 
      artists = response['response']['artists']         
      return artists unless artists.nil?
    end     
    begin      
      api_call.call
    rescue RuntimeError => e
      #retry api request
      retry_count++
      sleep(1)      
      retry unless (retry_count > 2)
    end              
  end

  def self.full_artist_name_match?(query_string, echonest_artist_object)    
    #return true if one of the returned echonest artists equals the query string entirely
    if ( query_string.downcase.gsub(echonest_artist_object['name'].downcase, '').length == 0  )
      return true
    else   
      return false
    end
  end

  def self.artist_song_combination?(query_string, echonest_artist_object)  
    query_string.downcase!
    echonest_artist_object['songs'].each do |song|       
      if(query_string.include?(song['title'].downcase) && query_string.include?(echonest_artist_object['name'].downcase))
        return true
      end      
    end    
    return false
  end
end
