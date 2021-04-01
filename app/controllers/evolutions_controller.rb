class EvolutionsController < AuthenticatedController

  before_action :require_session
  before_action :assign_evolution, only: [:edit, :show, :update, :start]

  def index
    @evolutions = current_user.evolutions
  end

  def new
    @vessels = current_user.player.vessels
  end

  def create
    @evolution = Evolution.new(valid_params)
    @evolution.user = current_user
    @evolution.save
    if @evolution.errors.any?
      flash[:error] = @evolution.errors.full_messages.to_sentence
      redirect_to new_evolution_path
    else
      redirect_to evolution_path(@evolution)
    end
  end

  def edit
  end

  def show
  end

  def update
    @evolution.update(params[:evolution])
  end

  def start
    @evolution.start!
  end

  private

  def assign_evolution
    @evolution = Evolution.find(params[:id])
  end

  def valid_params
    params.require(:evolution).permit(:name, :vessel_id)
  end

end
