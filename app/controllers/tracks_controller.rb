class TracksController < ApplicationController
  before_filter :load_playlist
  
  def index
    Rails.logger.debug"TracksController index called"
    @tracks = @playlist.tracks.where('track_id > ?', params[:after].to_i)
    respond_to do |format|
      format.js   {}
    end

  end

  def load
  # code to load the track into the player goes here
  redirect_to tracks_path   
  end

  def show
  end

  def edit
  end

  def destroy
  end

  private

  def load_playlist
    @playlist = Playlist.find(params[:playlist_id])
  end



end
