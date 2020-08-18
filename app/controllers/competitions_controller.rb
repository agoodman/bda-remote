class CompetitionsController < AuthenticatedController
  include Serviceable
  skip_before_action :verify_authenticity_token
#  acts_as_service :competition, only: [:index, :show]

  rescue_from ActiveRecord::RecordNotUnique, with: :duplicate_record

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
    @competition = Competition.create(params.require(:competition).permit(:name, :duration))
    redirect_to competition_path(@competition)
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
      format.html { redirect_to new_competition_path }
    end
  end
end
