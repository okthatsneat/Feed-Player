class RenamePostTableToPostsTable < ActiveRecord::Migration
  def change
  	rename_table :post, :posts
  end 
end
