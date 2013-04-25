class Post < ActiveRecord::Base
	attr_accessible :title, :body
	has_many :keyword_posts
	has_many :keywords, :through => :keyword_posts
end
