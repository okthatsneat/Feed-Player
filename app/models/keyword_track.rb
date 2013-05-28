class KeyWord_Track < ActiveRecord::Base
  belongs_to :keyword
  belongs_to :track

end
