class VariantGroupsController < AuthenticatedController
  include VariantEngine
  include Craft
  require "open-uri"

  before_action :require_session
  before_action :assign_evolution, only: [:new, :create]
  before_action :assign_variant_group, except: [:create, :new]

  def show
  end

  def generate
    @variant_group.generate_competition!
    redirect_to variant_group_path(@variant_group)
  end

  def new
    @key_options = {
      baseline: "steerMult,steerKiAdjust,steerDamping",
      dynamicDamping: "DynamicDampingMin,DynamicDampingMax,dynamicSteerDampingFactor",
      dynamicPitch: "DynamicDampingPitchMin,DynamicDampingPitchMax,dynamicSteerDampingPitchFactor",
      dynamicYaw: "DynamicDampingYawMin,DynamicDampingYawMax,dynamicSteerDampingYawFactor",
      dynamicRoll: "DynamicDampingRollMin,DynamicDampingRollMax,dynamicSteerDampingRollFactor",
      evasion: "minEvasionTime,evasionThreshold,evasionTimeThreshold",
      genetic: VariantEngine.all_keys.join(",")
    }
    @reference_types = [:baseline, :best, :weighted]
    @generation_strategy_options = VariantEngine.generation_strategies
    @selection_strategy_options = VariantEngine.selection_strategies
    @spread_factor = @evolution.variant_groups.last.spread_factor rescue 0.25
  end

  def create
    @variant_group = VariantGroup.new(valid_params)
    @variant_group.evolution = @evolution
    @variant_group.generation = @evolution.variant_groups.count

    # assign reference values
    reference_type = params[:variant_group][:reference_type] || "baseline" rescue "baseline"

    case reference_type.to_sym
    when :best
      latest_competition = @variant_group.baseline_values = @evolution.variant_groups.order(:generation).last.competition rescue nil
      unless latest_competition.nil?
        best_variant = latest_competition.rankings.order(:rank).first.vessel.variant
        unless best_variant.nil?
          @variant_group.baseline_values = best_variant.values
        end
      end
    when :weighted
      @variant_group.baseline_values = @evolution.variant_groups.order(:generation).last.result_values rescue nil
    end

    # default to the baseline of the craft file itself, if none other specified
    if @variant_group.baseline_values.nil?
      @variant_group.baseline_values = VariantEngine.reference_values_for(@evolution.vessel.craft_url, @variant_group.keys.split(","))
    end

    @variant_group.save
    redirect_to evolution_variant_group_path(@evolution, @variant_group)
  end

  private

  def assign_evolution
    @evolution = Evolution.find(params[:evolution_id])
  end

  def assign_variant_group
    @variant_group = VariantGroup.find(params[:id])
  end

  def valid_params
    params.require(:variant_group).permit(:keys, :generation_strategy, :selection_strategy, :spread_factor, :reference_type)
  end
end
