class PlaylistTrack < ActiveRecord::Base
  before_destroy :clean_up_unreferenced_tracks
  belongs_to :playlist
  belongs_to :track 
  attr_accessible :position, :playlist, :track

  private

  def clean_up_unreferenced_tracks 
  	self.track.destroy unless self.track.playlists.any?  
  end

end
