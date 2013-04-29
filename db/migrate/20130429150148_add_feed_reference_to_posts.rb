class AddFeedReferenceToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :feed_id, :int
  end
end
