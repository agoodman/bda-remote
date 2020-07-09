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

      r = Record.where(competition_id: rp['competition_id'], player: rp['player']).first_or_create
      r.hits = rp['hits'] 
      r.kills = rp['kills'] 
      r.deaths = rp['deaths']
      r.distance = rp['distance']
      r.weapon = rp['weapon']
      r.save
    end
    head :ok
  end

  def record_params(input)
    input.permit(:player, :competition_id, :hits, :kills, :deaths, :distance, :weapon)
  end

  def did_assign_collection
    @collection = @collection.where(competition_id: params[:competition_id])
  end

end
