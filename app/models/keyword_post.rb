class Keyword_Post < ActiveRecord::Base
attr_accessible :title_occurrence, :body_occurrence
belongs_to :keyword
belongs_to :post
end