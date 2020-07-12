class HeatsController < ApplicationController
  include Serviceable
  acts_as_service :heat, only: [:index, :show]

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
