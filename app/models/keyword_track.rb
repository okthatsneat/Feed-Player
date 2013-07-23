class KeywordTrack < ActiveRecord::Base
  attr_accessible :keyword_id, :track_id
  before_destroy :clean_up_unreferenced_keywords
  belongs_to :keyword
  belongs_to :track

  private
  
  def clean_up_unreferenced_keywords
  	self.keyword.destroy unless (self.keyword.tracks.any || self.keyword.posts.any?)	
  end

end
