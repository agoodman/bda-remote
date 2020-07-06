class RecordsController < ApplicationController
  include Serviceable
  skip_before_action :verify_authenticity_token
  acts_as_service :record, only: :index

  def batch
    @records = params['records']
    if @records.count > 100
      head :bad_request && return
    end
    @records.each do |p|
      rp = record_params(p)
      next unless rp

      Record.create_with(
	hits: rp['hits'], 
	kills: rp['kills'], 
	deaths: rp['deaths'],
	distance: rp['distance'],
	weapon: rp['weapon']
	).find_or_create_by(competition_id: rp['competition_id'], player: rp['player'])
    end
  end

  def record_params(input)
    input.permit(:player, :competition_id, :hits, :kills, :deaths, :distance, :weapon)
  end

  def did_assign_collection
    @collection = @collection.where(competition_id: params[:competition_id])
  end

end
