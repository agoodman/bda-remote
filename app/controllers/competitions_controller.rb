class CompetitionsController < ApplicationController
  include Serviceable
  skip_before_action :verify_authenticity_token
  acts_as_service :competition, only: [:index, :show]

  rescue_from ActiveRecord::RecordNotUnique, with: :duplicate_record

  def create
    @competition = Competition.create(params[:competition])
    redirect_to root_path
  end

  def start
    assign_existing_instance
    @instance.start!
    if @instance.started?
      redirect_to root_path
    else
      head :bad_request
    end
  end

  private

  def duplicate_record
    result = { error: "Name must be unique" }
    respond_to do |format|
      format.json { render json: result }
      format.xml { render xml: result }
    end
  end
end
