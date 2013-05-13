class FeedsController < ApplicationController
  # GET /feeds
  # GET /feeds.json
  def index
    @feeds = Feed.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @feeds }
    end
  end

  # GET /feeds/1
  # GET /feeds/1.json
  def show
    @feed = Feed.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @feed }
    end
  end

  # GET /feeds/new
  # GET /feeds/new.json
  def new
    @feed = Feed.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @feed }
    end
  end

  # GET /feeds/1/edit
  def edit
    @feed = Feed.find(params[:id])
  end

  # POST /feeds
  # POST /feeds.json
  def create
    @feed = Feed.new(params[:feed])
    respond_to do |format|
    # parse feed with Feedzirra and set attributes, create posts
    if (rss_parser = RSSParser.new(@feed))
      # get the embeded content and create tracks
      rss_parser.parse
      rss_parser.extract_tracks_from_embeds
      # pull the posts to create tracks from, query Soundcloud
      # TODO encapsulate in rss_parser.method
      @feed.posts.each do | post |
        soundcloud_track = 
        SoundcloudProvider.query_for_single_track_from_title(post.title)
        if soundcloud_track
          #create track with parent post
          Track.create_from_soundcloud_track(soundcloud_track, post)
        end
        post.tracks.each do |track|
          unless track.soundcloud_embed
            track.pull_soundcloud_embed
          end
        end
      end 
      format.html { redirect_to @feed, notice: 'Feed was successfully created.' }
      format.json { render json: @feed, status: :created, location: @feed }
    else
        format.html { render action: "new" }
        format.json { render json: @feed.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /feeds/1
  # PUT /feeds/1.json
  def update
    @feed = Feed.find(params[:id])

    respond_to do |format|
      if @feed.update_attributes(params[:feed])
        format.html { redirect_to @feed, notice: 'Feed was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @feed.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /feeds/1
  # DELETE /feeds/1.json
  def destroy
    @feed = Feed.find(params[:id])
    @feed.destroy

    respond_to do |format|
      format.html { redirect_to feeds_url }
      format.json { head :no_content }
    end
  end
end
