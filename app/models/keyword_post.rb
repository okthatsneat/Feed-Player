class KeywordPost < ActiveRecord::Base
	attr_accessible :title_occurrence, :body_occurrence, :keyword_id
	belongs_to :keyword
	belongs_to :post
end