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
    @rule = Rule.new
    strategy = params[:rule][:strategy].to_sym
    @rule.strategy = Rule::strategies[strategy]
    @rule.params = build_params(strategy)
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

  def build_params(strategy)
    properties = lambda do |params|
      {
          part: params[:rule][:properties][:part],
          mod: params[:rule][:properties][:name],
          key: params[:rule][:properties][:key],
          op: params[:rule][:properties][:op],
          value: params[:rule][:properties][:value]
      }
    end
    case strategy.to_sym
    when :part_exists
      return params[:rule][:part_exists]
    when :float_module_property, :int_module_property, :string_module_property
      return {
          part: params[:rule][:properties][:part],
          mod: params[:rule][:properties][:name],
          key: params[:rule][:properties][:key],
          op: params[:rule][:properties][:op],
          value: params[:rule][:properties][:value]
      }
    when :resource_property
      return {
          part: params[:rule][:properties][:part],
          res: params[:rule][:properties][:name],
          key: params[:rule][:properties][:key],
          op: params[:rule][:properties][:op],
          value: params[:rule][:properties][:value]
      }
    else
      puts "UNK: #{strategy}"
      return {}
    end
  end
end
