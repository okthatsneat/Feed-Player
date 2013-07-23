class KeywordPost < ActiveRecord::Base
  attr_accessible :title_occurrence, :body_occurrence, :keyword_id, :post_id
  before_destroy :clean_up_unreferenced_keywords
  belongs_to :keyword
  belongs_to :post 

  def self.create_keyword_with_post!(keyword, post_id)
    _keyword = Keyword.create!(value: keyword)
    KeywordPost.create!(keyword_id: _keyword.id, post_id: post_id)
  end

  private

  def clean_up_unreferenced_keywords
  	self.keyword.destroy unless (self.keyword.tracks.any || self.keyword.posts.any?)	
  end

end