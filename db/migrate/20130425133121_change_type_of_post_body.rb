class ChangeTypeOfPostBody < ActiveRecord::Migration
  def self.up
  	change_column :posts, :body, :text
  end
end
