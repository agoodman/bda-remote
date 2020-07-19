class Heats::VesselsController < ApplicationController
  def index
    @vessels = Heat.find(params[:heat_id]).vessels

    respond_to do |format|
      format.json { render json: @vessels }
      format.xml { render xml: @vessels }
      format.csv { headers['Content-Type'] ||= 'text/csv' }
    end
  end
end
