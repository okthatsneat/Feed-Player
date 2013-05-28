class PostParser
include HTTParty
  format :json

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

  def validate_and_create_tracks_semantically(artist_names)
    unless (artist_names.empty?)
      artist_names.each do |artist_name|             
        titles_found = look_for_discogs_artist_titles_in_post_title(artist_name)                    
        unless (titles_found.empty?)
          titles_found.each do |title|
            if (artist_name == title) 
              # break if not present in post.title twice!
              if ( (@post.title.match /#{title}/i).captures.length < 2  )
                break
              end 
            end
            #query provider
            query = artist_name + " " + title.gsub("#{artist_name}", "")
            soundcloud_track = SoundcloudProvider.query(query)
            #ceate track
            if (soundcloud_track)
              Rails.logger.debug"query for track created is #{query}"
              Track.create_from_soundcloud_track(soundcloud_track, @post)
              Rails.logger.debug"track is #{soundcloud_track.title}"
            end      
          end
          #set up keyword for this validated artist
          KeywordPost.create_keyword_with_post!(artist_name, @post.id)              
        else 
          if (search_term_present_in_body_or_summary?(artist_name) || Keyword.exists?(:value => artist_name))
            # TODO case only artist present ------------------------------------------------
            # query for latest, most popular track?
          end
        end
      end
    end
    #  case no artists detected -----------------------------------------------
    # TODO case Various Artists release not detected by Echonest           
    # TODO case only release title may be present in @post.title 
      # echonest extract artist on @post.summary 
      # discogs check for titles of those artists in @post.title  
  end

  def echonest_artist_song_in_provider_response(echonest_artist, soundcloud_response)
    # return first match of echonest artist song in soundcloud response item title
    echonest_artist['songs'].each do |song|
      soundcloud_response.each do |result|
        unless (result.empty?)
        #verify and return best result
          result.each do |item|
            unless (item.title =~ /#{song['title']}/i)
              next
            end
            #found a matching item              
            return item
          end
        end
      end
    end
  end

  def validate_and_create_tracks_after_provider_request(echonest_artist)
    #query provider with full post.title
    soundcloud_response = SoundcloudProvider.query_and_return_raw(@post.title)
    #traverse response checking for presence of songs by artists (from echonest)
    soundcloud track = echonest_artist_song_in_provider_response(echonest_artist, soundcloud_response)
    if soundcloud_track
      Track.create_from_soundcloud_track(soundcloud_track, @post)           
      #set up keyword for this validated artist
      KeywordPost.create_keyword_with_post!(echonest_artist['name'], @post.id)
    end
  end        

  private 



  def query_soundcloud_direct_with_post_title    
    soundcloud_track = 
    SoundcloudProvider.query(@post.title)
    if soundcloud_track
      #create track with parent post
      Track.create_from_soundcloud_track(soundcloud_track, @post)
    end
  end

  def look_for_discogs_artist_titles_in_post_title(artist_name)
    d = DiscogsApi.new    
    #pull list of discogs releases-titles for each keyword (=artist, found
    #by echonest)
    titles = d.list_titles_by_artist(artist_name)
    titles_found = []
    titles.each do |title|
      if (@post.title.downcase.include?(title.downcase))
        #check for self-titled releases
        titles_found << title
      end    
    end
    titles_found            
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
    # credit https://gist.github.com/afeld/1254889 for regex 
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
