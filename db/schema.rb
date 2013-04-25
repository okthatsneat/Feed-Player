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

ActiveRecord::Schema.define(:version => 20130425131523) do

  create_table "keyword_post", :force => true do |t|
    t.string   "title_occurrence"
    t.string   "body_occurrence"
    t.integer  "keyword_id"
    t.integer  "post_id"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  create_table "keyword_track", :force => true do |t|
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
    t.string   "body"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "tracks", :force => true do |t|
    t.string   "name"
    t.string   "title"
    t.string   "soundcould_uri"
    t.string   "spotify_uri"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.string   "soundcloud_url"
  end

end
