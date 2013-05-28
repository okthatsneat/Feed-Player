module TracksHelper


def soundcloud_embed(soundcloud_url)
  # create a client object with your app credentials
  client = Soundcloud.new(:client_id => '902d3c2d6d4c5c5f1dc5bee41cb01e2b')

  begin
    # get a tracks oembed data
    embed_info = client.get('/oembed', :url => soundcloud_url)
  
    # print the html for the player widget
    puts embed_info['html']

    # FIXME handle possible ResponseError
  rescue Exception => ex
    puts "Exception : #{ex.to_s}"
  end  
end

def soundcloud_embed?(soundcloud_url)
  #FIXME return false if 
  #embed_info = client.get('/oembed', :url => soundcloud_url)
  #returns Soundcloud::ResponseError: HTTP status: 403 
true
end




end
