class Track < ActiveRecord::Base
  attr_accessible :name, :soundcloud_uri, :soundcloud_url, :soundcloud_embed, 
  	:spotify_uri, :title
  has_many :keyword_tracks , :dependent => :destroy
  has_many :keywords, :through => :keyword_tracks
  has_and_belongs_to_many :posts

  def pull_soundcloud_embed
	  self.soundcloud_embed = SoundcloudProvider.get_embed_html5(self.soundcloud_uri)
	  Rails.logger.debug """

	  <<<<<<<<<<<<<<<<<<<<<<<<<<

	  self.soundcloud_embed is #{self.soundcloud_embed}

		>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
	  """
	  
	  self.save
  end

end
