class CompetitionsController < AuthenticatedController
  before_action :require_session, only: [:new, :create, :edit, :start, :unstart, :extend, :template, :duplicate, :publish, :unpublish]

  include Serviceable
  skip_before_action :verify_authenticity_token
#  acts_as_service :competition, only: [:index, :show]
#  skip_before_action :authenticate_user!, only: [:index, :show, :start]

  # rescue_from ActiveRecord::RecordNotUnique, with: :duplicate_record

  def index
    @competitions = Rails.cache.fetch("competitions") do
      Competition.order(updated_at: :desc)
    end
    respond_to do |format|
      format.json { render json: @collection }
      format.xml { render xml: @collection }
      format.html
    end 
  end

  def show
    @instance = cached_instance

    respond_to do |format|
      format.json { render json: @instance }
      format.xml { render xml: @instance }
      format.html
    end
  end

  def chart
    respond_to do |format|
      format.html
      format.json {
        @competition = cached_instance
        vessels = @competition.vessels
        vessel_ranks = {}
        vessels.each { |v| vessel_ranks[v.id] = [] }
        max_stage = @competition.heats.order(:stage).last.stage rescue 0
        # puts "max stage: #{max_stage}"
        all_records = @competition.records
        (0..max_stage).each do |stage|
          # generate a ranking of all players for the stage
          unordered_rankings = all_records.includes(heat: {}, vessel: :player).filter { |e| e.heat.stage <= stage }.group_by(&:vessel_id).map do |vessel_id,r|
            ranking = Ranking.new
            ranking.vessel_id = vessel_id
            ranking.kills = r.map(&:kills).sum
            ranking.deaths = r.map(&:deaths).sum
            ranking.assists = r.map(&:assists).sum
            ranking.hits_out = r.map(&:hits_out).sum
            ranking.hits_in = r.map(&:hits_in).sum
            ranking.dmg_out = r.map(&:dmg_out).sum
            ranking.dmg_in = r.map(&:dmg_in).sum
            ranking.mis_dmg_out = r.map(&:mis_dmg_out).sum
            ranking.mis_dmg_in = r.map(&:mis_dmg_in).sum
            ranking.mis_parts_out = r.map(&:mis_parts_out).sum
            ranking.mis_parts_in = r.map(&:mis_parts_in).sum
            ranking.ram_parts_out = r.map(&:ram_parts_out).sum
            ranking.ram_parts_in = r.map(&:ram_parts_in).sum
            ranking.death_order = r.map(&:death_order).sum
            ranking.death_time = r.map(&:death_time).sum
            ranking.wins = r.map(&:wins).sum
            ranking.score = @competition.metric.score_for_record(ranking)
            ranking.rank = 0
            ranking
          end
          sorted_rankings = unordered_rankings.sort_by { |e| e.score }.reverse
          sorted_rankings.each_with_index do |e, k|
            e.rank = k + 1
            ranks = vessel_ranks[e.vessel_id]
            if ranks.nil?
              vessel_ranks[e.vessel_id] = [e.rank]
            else
              vessel_ranks[e.vessel_id].push(e.rank)
            end
            # puts "vessel: #{e.vessel_id}, stage: #{stage}, rank: #{e.rank}"
          end
        end
        render json: vessel_ranks.keys.map { |k| {vessel_id: k, name: (vessels.where(id: k).first.name rescue "unk"), ranks: vessel_ranks[k] } }
      }
    end
  end

  def edit
    @competition = Competition.find(params[:id])
    @rulesets = Ruleset.all.map { |e| [e.name, e.id] }
    redirect_to competition_path(@competition) unless current_user == @competition.user
  end

  def update
    @competition = Competition.find(params[:id])
    @competition.update(valid_params)
    @competition.save
    redirect_to competition_path(@competition)
  end

  def results
    @competition = Rails.cache.fetch("results-#{params[:id]}") do
      Competition.includes(records: { vessel: :player }).find(params[:id])
    end
    respond_to do |format|
      format.csv
    end
  end

  def new
    @competition = Competition.new
    @rulesets = Ruleset.all
  end

  def create
    @competition = Competition.new(valid_params)
    @competition.user_id = current_user.id
    @competition.save
    if @competition.errors.any?
      flash[:error] = @competition.errors.full_messages.to_sentence
      redirect_to new_competition_path
    else
      redirect_to competition_path(@competition)
    end
  end

  def start
    @instance = Competition.find(params[:id])
    @instance.start!
    if @instance.started?
      redirect_to competition_path(@instance)
    else
      head :bad_request
    end
  end

  def unstart
    @instance = Competition.find(params[:id])
    redirect_to competition_path(@instance) and return if @instance.records.any? || current_user != @instance.user
    @instance.unstart!
    redirect_to competition_path(@instance)
  end

  def extend
    @instance = Competition.find(params[:id])
    if @instance.running?
      if params[:strategy] == "ranked"
        @instance.extend!(Armory::TournamentRankingStrategy.new)
      else
        @instance.extend!
      end
      redirect_to competition_path(@instance)
    else
      flash[:error] = "sorry, dave"
      head :bad_request
    end
  end

  def publish
    @instance = Competition.find(params[:id])
    if @instance.private?
      @instance.publish!
    end
    redirect_to competition_path(@instance)
  end

  def unpublish
    @instance = Competition.find(params[:id])
    if @instance.public?
      @instance.unpublish!
    end
    redirect_to competition_path(@instance)
  end

  def template
    @competitions = Competition.all
  end

  def duplicate
    src = Competition.find(params[:competition][:original_id])
    redirect_to template_competitions_path and return if src.nil?
    dst = Competition.create(name: params[:competition][:name], user_id: current_user.id)
    if dst.errors.any?
      flash[:error] = dst.errors
      redirect_to template_competitions_path and return
    end
    # copy vessels
    src.vessel_assignments.each do |e|
      dst.vessel_assignments.create(vessel_id: e.vessel_id)
    end
    # copy rules
    src.rules.each do |e|
      dst.rules.create(strategy: e.strategy, params: e.params)
    end
    redirect_to competition_path(dst)
  end

  private

  def cached_instance
    Rails.cache.fetch("competition-#{params[:id]}") do
      Competition.includes(
          players: {},
          records: {},
          vessels: :player,
          heats: { heat_assignments: { vessel: :player } }
      ).find(params[:id])
    end
  end

  def duplicate_record
    result = { error: "Name must be unique" }
    respond_to do |format|
      format.json { render json: result }
      format.xml { render xml: result }
      format.html { redirect_to new_competition_path }
    end
  end

  def valid_params
    params.require(:competition).permit(:name, :duration, :private, :ruleset_id, :max_stages)
  end
end
