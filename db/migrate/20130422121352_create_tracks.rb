class CreateTracks < ActiveRecord::Migration
  def change
    create_table :tracks do |t|
      t.string :name
      t.string :title
      t.string :soundcould_uri
      t.string :spotify_uri

      t.timestamps
    end
  end
end
