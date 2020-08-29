class RulesController < AuthenticatedController

  # before_action :require_session
  before_action :assign_competition

  def new
    @rule = Rule.new
  end

  def index
    @rules = @competition.rules
  end

  def create
    @rule = Rule.new(rule_params)
    @rule.competition_id = @competition.id
    @rule.save
    if @rule.errors.any?
      flash[:error] = @rule.errors.messages
      redirect_to new_competition_rule_path(params[:competition_id])
    else
      redirect_to competition_rules_path(params[:competition_id])
    end
  end

  def destroy
    @rule = Rule.find(params[:id])
    @rule.destroy
    redirect_to competition_rules_path(@competition)
  end

  def assign_competition
    @competition = Competition.find(params[:competition_id])
  end

  def rule_params
    params.require(:rule).permit([:strategy, :params])
  end
end
