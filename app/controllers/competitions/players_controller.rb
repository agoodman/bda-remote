class Competitions::PlayersController < ApplicationController
  def index
    @players = Competition.find(params[:competition_id]).players

    respond_to do |format|
      format.json { render json: @players }
      format.xml { render xml: @players }
      format.csv { headers['Content-Type'] ||= 'text/csv' }
    end
  end
end
