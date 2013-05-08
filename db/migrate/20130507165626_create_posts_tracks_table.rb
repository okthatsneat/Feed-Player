class CreatePostsTracksTable < ActiveRecord::Migration
  def change
    create_table :post_tracks, :id => false do |t|
      t.references :post
      t.references :track
    end
  end
end
