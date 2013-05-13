class Youtube

	def self.oembed(vid_id)
		vid = HTTParty.get("http://www.youtube.com/oembed?url=http://www.youtube.com/watch?v=#{vid_id}&format=json")
	end



end
