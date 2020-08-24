class CompetitionsController < AuthenticatedController
  before_action :require_session, only: [:new, :create, :start, :extend]

  include Serviceable
  skip_before_action :verify_authenticity_token
#  acts_as_service :competition, only: [:index, :show]
#  skip_before_action :authenticate_user!, only: [:index, :show, :start]

  # rescue_from ActiveRecord::RecordNotUnique, with: :duplicate_record

  def index
    @competitions = Competition.limit(10).order(:updated_at)
    respond_to do |format|
      format.json { render json: @collection }
      format.xml { render xml: @collection }
      format.html
    end 
  end

  def show
    query = Competition.includes(heats: { heat_assignments: { vessel: :player } })
    @instance = query.find(params[:id])
    respond_to do |format|
      format.json { render json: @instance }
      format.xml { render xml: @instance }
      format.html
    end
  end

  def new
    @competition = Competition.new
  end

  def create
    @competition = Competition.new(params.require(:competition).permit(:name, :duration))
    @competition.user_id = current_user.id
    @competition.save
    redirect_to competition_path(@competition.id)
  end

  def start
    @instance = Competition.find(params[:id])
    @instance.start!
    if @instance.started?
      redirect_to competition_path(@instance)
    else
      head :bad_request
    end
  end

  def extend
    @instance = Competition.find(params[:id])
    if @instance.running?
      @instance.extend!
      redirect_to competition_path(@instance)
    else
      flash[:error] = "sorry, dave"
      head :bad_request
    end
  end

  private

  def duplicate_record
    result = { error: "Name must be unique" }
    respond_to do |format|
      format.json { render json: result }
      format.xml { render xml: result }
      format.html { redirect_to new_competition_path }
    end
  end
end
