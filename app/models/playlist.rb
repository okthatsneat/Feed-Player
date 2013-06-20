class Playlist < ActiveRecord::Base
  has_one :playlist_track, :dependent => :destroy
  has_many :tracks, :through => :playlist_track
  has_and_belongs_to_many :feeds
  attr_accessible :title, :description, :feeds_attributes
  accepts_nested_attributes_for :feeds

  # def tracks
  # self.feeds.collect(&:posts).flatten.collect(&:tracks)

  # end

end
