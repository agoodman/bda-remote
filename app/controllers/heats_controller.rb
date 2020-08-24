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
    head :ok
  end

  def stop
    assign_existing_instance
    @instance.stop!

    # check if competition has any more heats
    comp = @instance.competition
    unless comp.has_remaining_heats?(comp.stage)
      comp.next_stage
    end
    head :ok
  end

  def reset
    assign_existing_instance
    @instance.reset!
    redirect_to competition_path(params[:competition_id])
  end

  def did_assign_collection
    @collection = @collection.where(competition_id: params[:competition_id])
  end

end
