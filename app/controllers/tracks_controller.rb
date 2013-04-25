class TracksController < ApplicationController
	
	def index
	@tracks = Track.all
	respond_to do |format|
	      format.html # index.html.erb
	      format.json { render json: @tracks }
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


end
