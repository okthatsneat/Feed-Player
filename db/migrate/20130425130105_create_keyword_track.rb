class CreateKeywordTrack < ActiveRecord::Migration
   def change
    create_table :keyword_track do |t|
      t.references :keyword
      t.references :track
      t.timestamps
    end
  end
end
