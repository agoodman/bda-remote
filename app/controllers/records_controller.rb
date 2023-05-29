class RecordsController < ApplicationController
  include Serviceable
  skip_before_action :verify_authenticity_token
  acts_as_service :record, only: :index

  before_action :check_authorization, only: :batch

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
      r.hits_out = rp['hits_out'] rescue 0
      r.hits_in = rp['hits_in'] rescue 0
      r.dmg_out = rp['dmg_out'] rescue 0
      r.dmg_in = rp['dmg_in'] rescue 0
      r.kills = rp['kills'] rescue 0
      r.deaths = rp['deaths'] rescue 0
      r.assists = rp['assists'] rescue 0
      r.mis_dmg_out = rp['mis_dmg_out'] rescue 0
      r.mis_dmg_in = rp['mis_dmg_in'] rescue 0
      r.mis_parts_out = rp['mis_parts_out'] rescue 0
      r.mis_parts_in = rp['mis_parts_in'] rescue 0
      r.ram_parts_out = rp['ram_parts_out'] rescue 0
      r.ram_parts_in = rp['ram_parts_in'] rescue 0
      r.roc_dmg_out = rp['roc_dmg_out'] rescue 0
      r.roc_dmg_in = rp['roc_dmg_in'] rescue 0
      r.roc_parts_out = rp['roc_parts_out'] rescue 0
      r.roc_parts_in = rp['roc_parts_in'] rescue 0
      r.distance = rp['distance']
      r.weapon = rp['weapon']
      r.death_order = rp['death_order'] rescue 0
      r.death_time = rp['death_time'] rescue 0
      r.wins = rp['wins'] rescue 0
      r.waypoints = rp['waypoints'] rescue 0
      r.elapsed_time = rp['elapsed_time'] rescue 0
      r.deviation = rp['deviation'] rescue 0
      r.ast_parts_in = rp['ast_parts_in'] rescue 0
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
    input.permit(:vessel_id,
                 :hits_out,
                 :hits_in,
                 :kills,
                 :deaths,
                 :assists,
                 :distance,
                 :weapon,
                 :dmg_in,
                 :dmg_out,
                 :mis_dmg_in,
                 :mis_dmg_out,
                 :mis_parts_in,
                 :mis_parts_out,
                 :ram_parts_in,
                 :ram_parts_out,
                 :roc_dmg_in,
                 :roc_dmg_out,
                 :roc_parts_in,
                 :roc_parts_out,
                 :death_order,
                 :death_time,
                 :wins,
                 :waypoints,
                 :elapsed_time,
                 :deviation,
                 :ast_parts_in)
  end

  def did_assign_collection
    @collection = @collection.where(competition_id: params[:competition_id])
  end

  def check_authorization
    current_comp = Competition.find(params[:competition_id])
    reject_request and return if params[:client_secret].nil? || params[:client_secret] != current_comp.secret_key
  end

  def reject_request
    response = { error: "Unauthorized" }
    respond_to do |format|
      format.json { render json: response, status: :unauthorized }
      format.all { render nothing: true, status: :unauthorized }
    end
  end

end
