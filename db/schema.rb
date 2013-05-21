# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130521104827) do

  create_table "feeds", :force => true do |t|
    t.string   "url"
    t.string   "title"
    t.string   "feed_url"
    t.string   "etag"
    t.datetime "last_modified"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.string   "top_level_domain"
  end

  add_index "feeds", ["feed_url"], :name => "index_feeds_on_feed_url", :unique => true

  create_table "keyword_posts", :force => true do |t|
    t.string   "title_occurrence"
    t.string   "body_occurrence"
    t.integer  "keyword_id"
    t.integer  "post_id"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  create_table "keyword_tracks", :force => true do |t|
    t.integer  "keyword_id"
    t.integer  "track_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "keywords", :force => true do |t|
    t.string   "value"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "posts", :force => true do |t|
    t.string   "title"
    t.text     "body",         :limit => 255
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
    t.text     "summary"
    t.string   "url"
    t.datetime "published_at"
    t.string   "guid"
    t.integer  "feed_id"
  end

  add_index "posts", ["guid"], :name => "index_posts_on_guid", :unique => true

  create_table "posts_tracks", :id => false, :force => true do |t|
    t.integer "post_id"
    t.integer "track_id"
  end

  create_table "tracks", :force => true do |t|
    t.string   "name"
    t.string   "title"
    t.string   "soundcloud_uri"
    t.string   "spotify_uri"
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
    t.string   "soundcloud_url"
    t.text     "soundcloud_embed"
    t.string   "youtube_id"
    t.text     "youtube_embed",    :limit => 255
  end

  add_index "tracks", ["soundcloud_uri"], :name => "index_tracks_on_soundcloud_uri", :unique => true
  add_index "tracks", ["youtube_id"], :name => "index_tracks_on_youtube_id", :unique => true

end
