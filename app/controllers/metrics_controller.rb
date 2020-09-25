class MetricsController < AuthenticatedController

  def edit
    @competition = Competition.find(params[:competition_id])
    redirect_to competition_path(@competition) and return unless current_user == @competition.user
  end

  def update
    @competition = Competition.find(params[:competition_id])
    redirect_to competition_path(@competition) and return unless current_user == @competition.user
    options = params
                  .require(:metric)
                  .permit(
                      :kills,
                      :deaths,
                      :assists,
                      :hits_out,
                      :dmg_out,
                      :mis_dmg_out,
                      :mis_parts_out,
                      :ram_parts_out,
                      :hits_in,
                      :dmg_in,
                      :mis_dmg_in,
                      :mis_parts_in,
                      :ram_parts_in
                  )
    @competition.metric.update(options)
    @competition.update_rankings!
    redirect_to edit_competition_path(@competition)
  end

end
