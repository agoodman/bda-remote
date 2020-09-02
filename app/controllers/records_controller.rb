class RecordsController < ApplicationController
  include Serviceable
  skip_before_action :verify_authenticity_token
  acts_as_service :record, only: :index

  def batch
    @records = params['records']
    if @records.count > 100
      head :bad_request && return
    end
    c = Competition.find(params[:competition_id])
    h = Heat.find(params[:heat_id])
    unless c.running? && h.running?
      respond_to do |format|
        format.json { render json: { error: "Competition not running" }, status: :unprocessable_entity }
      end
      return
    end

    results = @records.map do |p|
      rp = record_params(p)
      status = {}
      unless rp
        status[:success] = false
        status[:message] = "invalid record params: #{rp}"
        next
      end

      r = Record.where(competition_id: c.id, heat_id: h.id, vessel_id: rp['vessel_id']).first_or_create
      r.hits = rp['hits'] rescue 0
      r.kills = rp['kills'] rescue 0
      r.deaths = rp['deaths'] rescue 0
      r.assists = rp['assists'] rescue 0
      r.distance = rp['distance']
      r.weapon = rp['weapon']
      r.save

      if r.errors.any?
        status[:message] = r.errors.full_messages
      else
        status[:id] = r.id
        status[:created_at] = r.created_at
      end

      status
    end

    respond_to do |format|
      format.json { render json: results }
    end
  end

  def record_params(input)
    input.permit(:vessel_id, :hits, :kills, :deaths, :distance, :weapon)
  end

  def did_assign_collection
    @collection = @collection.where(competition_id: params[:competition_id])
  end

end
