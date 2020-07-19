class HeatsController < ApplicationController
  include Serviceable
  acts_as_service :heat, only: :show

  def index
    @heats = Heat.where(competition_id: params[:competition_id])

    respond_to do |format|
      format.json { render json: @heats }
      format.xml { render xml: @heats }
      format.csv { headers['Content-type'] ||= 'text/csv' }
    end
  end

  def start
    assign_existing_instance
    @instance.start!
  end

  def stop
    assign_existing_instance
    @instance.stop!
  end

  def did_assign_collection
    @collection = @collection.where(competition_id: params[:competition_id])
  end

end
