class Competitions::VesselsController < AuthenticatedController

  before_action :require_session
  before_action :assign_competition

  def index
    @vessels = current_user.player.vessels rescue []
  end

  def create
    redirect_to competition_vessels_path(@competition) and return unless @competition.status == 0
    @vessel_assignment = VesselAssignment.where(
        competition_id: params[:competition_id],
        vessel_id: params[:vessel_assignment][:vessel_id]).first_or_create
    redirect_to competition_vessels_path(@competition)
  end

  def destroy
    redirect_to competition_vessels_path(@competition) and return unless @competition.status == 0
    @vessel_assignment = VesselAssignment.find(params[:id])
    @vessel_assignment.destroy
    redirect_to competition_vessels_path(@competition)
  end

  def assign_competition
    @competition = Competition.find(params[:competition_id])
  end
end
