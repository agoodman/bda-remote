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
    @ruleset = Ruleset.create(params.require(:ruleset).permit(:name))
    redirect_to ruleset_path(@ruleset)
  end

  def update
    @ruleset = Ruleset.find(params[:id])
    @ruleset.update(params.require(:ruleset).permit(:name))
    redirect_to ruleset_path(@ruleset)
  end

end
