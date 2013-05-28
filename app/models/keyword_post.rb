class KeywordPost < ActiveRecord::Base
  attr_accessible :title_occurrence, :body_occurrence, :keyword_id, :post_id
  belongs_to :keyword
  belongs_to :post

  def self.create_keyword_with_post!(keyword, post_id)
    _keyword = Keyword.create!(value: keyword)
    KeywordPost.create!(keyword_id: _keyword.id, post_id: post_id)
  end

end