class MetricsController < AuthenticatedController

  def edit
    @competition = Competition.find(params[:competition_id])
    redirect_to competition_path(@competition) and return unless current_user == @competition.user
  end

  def update
    @competition = Competition.find(params[:competition_id])
    redirect_to competition_path(@competition) and return unless current_user == @competition.user
    @competition.metric.update(params.require(:metric).permit(:kills, :deaths, :assists, :hits_out, :dmg_out, :hits_in, :dmg_in))
    redirect_to edit_competition_path(@competition)
  end

end
