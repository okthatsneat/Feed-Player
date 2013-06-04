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

  def query_string_for_coverart_image
    if (coverart_url = get_coverart_url)
      google_reverse_image_search_base = "https://www.google.com/searchbyimage?&image_url="
      user_agent = "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.11 (KHTML, like Gecko) Chrome/23.0.1271.97 Safari/537.11"
      response = HTTParty.get(google_reverse_image_search_base + coverart_url, :headers => {"User-Agent" => user_agent})
      _doc = Nokogiri::HTML(response)
      xpath_query = "//body/div[@id='main']/div/div[@id='cnt']/div[@id='rcnt']/div[@id='center_col']/div[@id='res']/div[@id='topstuff']"
      return _doc.at(xpath_query).children.last.children.children.text
    else
      return false
    end
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

  private

  def get_coverart_url
    unless @doc.css("meta[property='og:image']").blank?
      coverart_url = @doc.css("meta[property='og:image']").first.attributes["content"].value
      return CGI.escape(coverart_url)      
    end
    
  end

end
