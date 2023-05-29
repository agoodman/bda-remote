class MetricsController < AuthenticatedController

  def edit
    @competition = Competition.find(params[:competition_id])
    redirect_to competition_path(@competition) unless @competition.user_can_manage?(current_user)
  end

  def update
    @competition = Competition.find(params[:competition_id])
    redirect_to competition_path(@competition) and return unless @competition.user_can_manage?(current_user)
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
                      :ram_parts_in,
                      :wins,
                      :roc_dmg_in,
                      :roc_parts_in,
                      :roc_dmg_out,
                      :roc_parts_out,
                      :death_order,
                      :death_time,
                      :waypoints,
                      :elapsed_time,
                      :deviation,
                      :ast_parts_in
                  )
    @competition.metric.update(options)
    @competition.update_rankings!
    redirect_to edit_competition_path(@competition)
  end

end
