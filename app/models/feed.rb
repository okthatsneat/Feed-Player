class Feed < ActiveRecord::Base
  attr_accessible :etag, :feed_url, :last_modified, :title, :url
  has_many :posts
end
