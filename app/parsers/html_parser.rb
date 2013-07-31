class HtmlParser
  @@file_name_helper = 0 
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
      # if google has a best guess for us it'll have this div element  
      if (best_guess_div  = _doc.xpath('//div[contains(text(), "Best guess")]'))
        # that's the text element with the best guess value of that div  
        return best_guess_div.children.children.to_s       
      else        
        return false
      end      
    else
      return false
    end
  end  

  private

  def get_coverart_url
    unless @doc.css("meta[property='og:image']").blank?
      coverart_url = @doc.css("meta[property='og:image']").first.attributes["content"].value
      return CGI.escape(coverart_url)      
    else
      return false
    end    
  end

end
