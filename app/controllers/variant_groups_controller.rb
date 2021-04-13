class VariantGroupsController < AuthenticatedController

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
      evasion: "minEvasionTime,evasionThreshold,evasionTimeThreshold"
    }
    @spread_factor = @evolution.variant_groups.last.spread_factor rescue 0.25
  end

  def create
    @variant_group = VariantGroup.new(valid_params)
    @variant_group.evolution = @evolution
    @variant_group.generation = @evolution.variant_groups.count
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
    params.require(:variant_group).permit(:keys)
  end
end
