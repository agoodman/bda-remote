class VariantGroupsController < AuthenticatedController

  before_action :require_session
  before_action :assign_variant_group

  def show
  end

  def generate
    @variant_group.generate_competition!
    redirect_to variant_group_path(@variant_group)
  end

  private

  def assign_variant_group
    @variant_group = VariantGroup.find(params[:id])
  end
end
