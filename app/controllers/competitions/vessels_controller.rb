class Competitions::VesselsController < AuthenticatedController

  require "open-uri"
  include Craft

  before_action :require_session, except: [:manifest]
  before_action :assign_competition
  before_action :require_ownership, only: [:manage, :reject]

  def index
    @vessels = current_user.player.vessels rescue []
  end

  def manage
    @vessels = @competition.vessels
  end

  def reject
    va = @competition.vessel_assignments.where(vessel_id: params[:id]).first
    # remove all heat assignments for this vessel in this competition
    HeatAssignment.includes(:heat).where(heats: { competition_id: @competition.id }).where(vessel_id: params[:id]).find_each { |e| e.destroy }
    va.destroy unless va.nil?
    redirect_to manage_competition_vessels_path(@competition)
  end

  def manifest
    respond_to do |format|
      format.json { render json: @competition.vessels, status: :ok }
      format.xml { render xml: @competition.vessels, status: :ok }
      format.csv { headers['Content-type'] ||= 'text/csv' }
    end
  end

  def new
  end

  # receive an uploaded craft file, create a vessel, and assign it to the competition
  def assign
    # shamelessly stolen copypasta from vessels#create
    s3 = Aws::S3::Resource.new(region: ENV['AWS_REGION'])
    bucket = s3.bucket(ENV['S3_BUCKET'])
    redirect_to new_competition_vessel_path(@competition) and return if bucket.nil?

    player = current_user.player
    forced = params[:vessel][:force].to_i == 1 rescue false
    @vessel = Vessel.where(player_id: player.id, name: params[:vessel][:name]).first
    if !@vessel.nil? && !forced
      flash[:error] = "Vessel name must be unique"
      redirect_to new_competition_vessel_path(@competition) and return
    end

    file = params[:file]

    unless file.original_filename.ends_with?(".craft")
      flash[:error] = "File must have .craft extension"
      redirect_to new_competition_vessel_path(@competition) and return
    end

    if file.size > 5242880
      flash[:error] = "File too large (max 5MB)"
      redirect_to new_competition_vessel_path(@competition) and return
    end

    unless is_craft_file_valid?(file, @competition.validation_strategies)
      redirect_to new_competition_vessel_path(@competition) and return
    end

    filename = "players/#{player.id}/#{file.original_filename}"
    s3obj = bucket.object(filename)
    s3obj.put(
        body: file,
        acl: "public-read"
    )

    # craft_url = "url-#{Time.now.to_f}"
    craft_url = s3obj.public_url
    if @vessel.nil?
      @vessel = Vessel.create(player_id: player.id, craft_url: craft_url, name: params[:vessel][:name])
      @vessel_assignment = VesselAssignment.where(
          competition_id: @competition.id,
          vessel_id: @vessel.id).first_or_create
    else
      @vessel.update(craft_url: craft_url)
    end

    all_assignments = @competition.vessel_assignments.includes(:vessel).where(vessels: { player_id: player.id }).order(:created_at)
    if all_assignments.count > @competition.max_vessels_per_player
      all_assignments.first.destroy
    end

    if @vessel.errors.any?
      flash[:error] = @vessel.errors
      redirect_to new_player_vessel_path(player) and return
    end

    redirect_to competition_path(@competition)
  end

  def create
    redirect_to competition_vessels_path(@competition) and return unless @competition.status == 0

    # fetch and validate craft
    @vessel = Vessel.find(params[:vessel_assignment][:vessel_id])

    # skip validation for NPCs
    if @vessel.player.is_human
      craft = URI::open(@vessel.craft_url).read
      unless is_craft_valid?(craft, @competition.validation_strategies)
        redirect_to competition_vessels_path(@competition) and return
      end
    end

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

  def require_ownership
    redirect_to competition_path(@competition) unless @competition.user == current_user
  end
end
