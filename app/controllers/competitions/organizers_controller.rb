class Competitions::OrganizersController < AuthenticatedController

  before_action :assign_competition
  before_action :reject_unauthorized

  def index
    @players = Player.includes(:user).where.not(user_id: @competition.organizers.map(&:user_id))
  end

  def create
    @competition.organizers.create(user_id: params[:organizer][:user_id])
    redirect_to competition_organizers_path(@competition)
  end

  def destroy
    existing = Organizer.find(params[:id])
    existing.destroy if existing
    redirect_to competition_organizers_path(@competition)
  end

  private

  def assign_competition
    @competition = Competition.find(params[:competition_id])
  end

  def reject_unauthorized
    redirect_to competition_path(@competition) unless @competition.user_can_manage?(current_user)
  end
end
