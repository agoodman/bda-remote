class CompetitionsController < ApplicationController

  def index
    @collection = Record.pluck(:competition_id).uniq
    respond_to do |format|
      format.json { render json: @collection.to_json }
      format.xml { render xml: @collection.to_xml }
    end
  end

end
