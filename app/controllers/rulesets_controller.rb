class RulesetsController < AuthenticatedController

  before_action :require_session

  def index
    @rulesets = Ruleset.all
  end

  def show
    @ruleset = Ruleset.find(params[:id])
  end

  def new
    @ruleset = Ruleset.new
  end

  def create
    @ruleset = Ruleset.create(ruleset_params)
    redirect_to ruleset_path(@ruleset)
  end

  def edit
    @ruleset = Ruleset.find(params[:id])
  end

  def update
    @ruleset = Ruleset.find(params[:id])
    @ruleset.update(ruleset_params)
    redirect_to ruleset_path(@ruleset)
  end

  private

  def ruleset_params
    params.require(:ruleset).permit([:name, :summary])
  end
end
