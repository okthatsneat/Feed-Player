class AddPropertiesToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :summary, :text
    add_column :posts, :url, :string
    add_column :posts, :published_at, :datetime
    add_column :posts, :guid, :string
  end
end
