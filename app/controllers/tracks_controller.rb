class TracksController < ApplicationController
  before_filter :load_playlist
  
    def index
    Rails.logger.debug"TracksController index called"
    # pattern analogous to Ryan Bate's Railscast http://railscasts.com/episodes/229-polling-for-changes-revised?view=asciicast
    @tracks = @playlist.tracks.where('track_id > ?', params[:after].to_i)
    respond_to do |format|
      format.js   {}
    end
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
