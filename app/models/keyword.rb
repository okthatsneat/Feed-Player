class Keyword < ActiveRecord::Base
  attr_accessible :value, :keyword_posts_attributes
  has_many :keyword_posts , :dependent => :destroy
  has_many :keyword_tracks, :dependent => :destroy
  has_many :posts, :through => :keyword_posts
  has_many :tracks, :through => :keyword_tracks
  accepts_nested_attributes_for :keyword_posts, :allow_destroy => true
end

