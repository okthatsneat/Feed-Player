class KeywordTrack < ActiveRecord::Base
  belongs_to :keyword
  belongs_to :track

end
