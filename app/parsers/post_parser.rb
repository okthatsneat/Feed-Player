class PostParser

  def initialize(post_id)
    @post = Post.find(post_id)
  end

  def extract_tracks_from_embeds
    #strategy: first extract from body and summary feed fields. if none present
    #head over to the post.url and check there.
    player_urls = []
    player_urls = HtmlParser.new(@post.summary).extract_player_urls_from_iframes
    player_urls.concat(HtmlParser.new(@post.body).extract_player_urls_from_iframes)    
    unless player_urls.empty?
      unless (create_tracks_from_player_urls(player_urls))
        # have to head over to the website to check for embeded content
        # all player_urls were not supported yet
        return create_tracks_from_embeds_on_website_behind_post        
      else
        return true
      end  
    else
      # no player_urls where found in neither summary nor body, so head over to the 
      # website to check for embeded content
      return create_tracks_from_embeds_on_website_behind_post
    end
    return false    
  end

  #stategy - extract coverart from post, reverse google image search that,
  #query provider whith google's guess what this image represents. 
  def create_tracks_for_coverart    
    query_string = HtmlParser.new(
      HTTParty.get(@post.url)).query_string_for_coverart_image
    Rails.logger.debug"query string from google is (#{query_string})"
    # validate query string to represent either an artist name, or an 
    # artist-song, artist-release combination. reject if not.
    #get Echonest artist objects
    if (query_string)
      EchonestApi.extract_artist_objects_from_string(query_string).each do |echonest_artist_object|
        #check if 100% artist name match
        is_artist_name = EchonestApi.full_artist_name_match?(query_string, echonest_artist_object)
        # check if Artist and song combination - not useful; an image representing an artist-song combination rarely exists
        # is_artist_song = EchonestApi.artist_song_combination?(query_string, echonest_artist_object)
        # check if Artist and release combination
        is_artist_release = DiscogsApi.new().artist_release_combination?(query_string, echonest_artist_object)
          # save found artist keyword, query provider with query string
        if (is_artist_name || is_artist_release)
          Rails.logger.debug"""
          <<< in create_tracks_for_coverart 

          query_string is #{query_string}
          is_artist_name is #{is_artist_name} 
          is_artist_release is #{is_artist_release}
          echonest_artist_object['name'] is #{echonest_artist_object['name']}

          >>>>
          """

          # save found artist as keyword
          KeywordPost.create_keyword_with_post!(echonest_artist_object['name'], @post.id)
          # query provider with validated string 
          if (soundcloud_track = SoundcloudProvider.query(query_string))
            Track.create_from_soundcloud_track(soundcloud_track, @post)
            return true
          end        
        end
      end
      #iterated through all echonest artist objects, didn't create a track, so strategy fail
      return false
    else
      # no query string, so no dice. 
      return false
    end    
  end

  # great idea, but at 1 request per second and ip rate limit (discogs) a little slow. 
  # great with a commercial api key.  
  def validate_and_create_tracks_semantically
    Rails.logger.debug"in validate_and_create_tracks_semantically for post #{@post.title}"
    artist_names = EchonestApi.extract_artists_from_titles(@post.id)
    Rails.logger.debug"Echonest artist names for post #{@post.title} are #{artist_names}"
    unless (artist_names.empty?)
      artist_names.each do |artist_name|
        #get a response object from discogs with all main releases for that artist
        d = DiscogsApi.new
        titles = d.list_titles_by_artist(artist_name) # format is {:release_id=>"1", :release_title=>"title"}
        #check that object for post.title release title matches
        titles_found = look_for_discogs_artist_titles_in_post_title(titles)
        Rails.logger.debug"titles_found for artist #{artist_name} are #{titles_found}"                    
        unless (titles_found.empty?)
          titles_found.each do |title|
            Rails.logger.debug"found title #{title} for artist #{artist_name}"
            if (artist_name.eql?(title)) 
              # break if not present in post.title twice
              Rails.logger.debug"artist name #{artist_name} equals title #{title}" 
              if ( (@post.title.match(/#{title}/i)).captures.length < 2  )
                break
              end 
            end
            #set up keyword for this validated artist
            KeywordPost.create_keyword_with_post!(artist_name, @post.id)
            #found valid artist - release combo, so query provider with that
            query = artist_name + " " + title
            return query_soundcloud_and_create_track(query)            
          end          
        else
          #if non found, check for post.title artist song matches
          if (songs = d.list_songs_by_releases(titles))
            song_found = look_for_discogs_artist_song_in_post_title(songs)
            if (song_found)
              #set up keyword for validated artist
              KeywordPost.create_keyword_with_post!(artist_name, @post.id)
              #query artist_name song combination
              query = artist_name + ' ' + song_found
              return query_soundcloud_and_create_track(query)          
            end          
          end          
        end
      end
      return false
    else    
      return false
    end
  end

  private

  # this one will proove handy sometime, and should be included into the semantic algorithm to optimize
  # detection rate. 
  def echonest_artist_song_in_provider_response(echonest_artist, soundcloud_response)
    # return first match of echonest artist song in soundcloud response item title
    matching_soundcloud_items = []
    #array of format [playlists[], tracks[]]
    soundcloud_response.each do |result|            
      unless (result.empty?)
      #verify and return best results: both artist and song by artist present in title - good match. 
        result.each do |item|
          echonest_artist['songs'].each do |song|
            match_condition1 = ((item.title =~ /#{CGI.escape(song['title'])}/i) && (item.title =~ /#{CGI.escape(echonest_artist['name'])}/i))
            match_condition2 = ((item.title =~ /#{CGI.escape(song['title'])}/i) && (item.user.username =~ /#{CGI.escape(echonest_artist['name'])}/i))
            if ( match_condition1 || match_condition2 )
              matching_soundcloud_items << item
              puts "#{item.title} added"          
            end
          end
        end
      end
    end
    return matching_soundcloud_items
  end
     
  # experimental, not in use. 
  def query_soundcloud_direct_with_post_title    
    soundcloud_track = 
    SoundcloudProvider.query(@post.title)
    if soundcloud_track
      #create track with parent post
      Track.create_from_soundcloud_track(soundcloud_track, @post)
    end
  end

  def look_for_discogs_artist_titles_in_post_title(titles)
    titles_found = []
    #FIXME
    titles.each do |title|     
      if (@post.title =~ /\b#{title[:release_title]}\b/i)
        titles_found << title[:release_title]
      end
    end
    titles_found            
  end

  #takes an array of songs
  def look_for_discogs_artist_song_in_post_title(songs)
    Rails.logger.debug"songs are #{songs}"
    Rails.logger.debug"@post.title is (#{@post.title})"
    songs.each do |song|
      if (song)
        if (@post.title =~ /\b#{song}\b/i)
          return song
        end
      end
    end
    return false
  end

  def query_soundcloud_and_create_track(query)
    soundcloud_track = SoundcloudProvider.query(query)
    #ceate track
    if (soundcloud_track)
      Rails.logger.debug"query for track created is #{query} from post title #{@post.title}"
      Track.create_from_soundcloud_track(soundcloud_track, @post)
      Rails.logger.debug"soundcloud track is #{soundcloud_track.title}"
      return true
    else
      Rails.logger.debug"query for soundcloud track NOT created is #{query} for post title #{@post.title}"
      return false
    end
  end



  def create_tracks_from_embeds_on_website_behind_post
    player_urls = HtmlParser.new(
      HTTParty.get(@post.url)).extract_player_urls_from_iframes
    unless (player_urls.empty?)
      return create_tracks_from_player_urls(player_urls)
    end
    return false
  end

  def create_tracks_from_player_urls(player_urls)
    @re_soundcloud = /(api\.soundcloud\.com[^&]*)/
    # credit: https://gist.github.com/afeld/1254889 for youtube regex 
    @re_youtube = /(youtu\.be\/|youtube\.com\/(watch\?(.*&)?v=|(embed|v)\/))([^\?&"'>]+)/
    player_urls.each do |player_url|
      player_type = identify_player_type(player_url)
      case player_type
        when "Soundcloud"
          #resolve soundcloud uri to track
          soundcloud_uri = (player_url.match @re_soundcloud).captures[0] 
          soundcloud_track = SoundcloudProvider.resolve_uri_to_track(soundcloud_uri)
          Track.create_from_soundcloud_track(soundcloud_track, @post)
          return true
        when "Youtube"
          vid_id = (player_url.match @re_youtube).captures[4] 
          if (youtube_vid = Youtube.oembed(vid_id)) 
            Track.create_from_youtube_vid(vid_id, youtube_vid, @post)
            return true
          end          
        else
          return false                
      end
    end
  end

  def search_term_present_in_body_or_summary?(search_term)
    (@post.summary =~ /#{search_term}/i) || (@post.body =~ /#{search_term}/i)
  end

  def present_in_post_summary?(artist_name)
    @post.summary.include?(artist_name)
  end

  def identify_player_type(player_url)
    # switch depending on type
    if (player_url =~ @re_soundcloud)
      return "Soundcloud"
    elsif (player_url =~ @re_youtube)
      return "Youtube"
    else
       return "None"
    end
  end

end
