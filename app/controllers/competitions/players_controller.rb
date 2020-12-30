class Competitions::PlayersController < ApplicationController

  before_action :assign_competition

  def index
    @players = @competition.players
    @npcs = Player.npc

    respond_to do |format|
      format.html
      format.json { render json: @players }
      format.xml { render xml: @players }
      format.csv { headers['Content-Type'] ||= 'text/csv' }
    end
  end

  def new
    @player = Player.new
  end

  def create
    s3 = Aws::S3::Resource.new(region: ENV['AWS_REGION'])
    bucket = s3.bucket(ENV['S3_BUCKET'])
    redirect_to new_competition_vessel_path(competition_id: params[:competition_id]) and return if bucket.nil?

    file = params[:player][:craft]

    unless @competition.status == 0
      flash[:error] = "Competition is not accepting players"
      redirect_to competition_path(@competition) and return
    end

    unless file.original_filename.ends_with?(".craft")
      flash[:error] = "File must have .craft extension"
      redirect_to new_competition_player_path(@competition) and return
    end

    if file.size > 5242880
      flash[:error] = "File too large (max 5MB)"
      redirect_to new_competition_player_path(@competition) and return
    end

    player = Player.npc.where(user_id: 1, name: params[:player][:name]).first_or_create
    filename = "players/#{player.id}/#{file.original_filename}"
    s3obj = bucket.object(filename)
    s3obj.put(
        body: file,
        acl: "public-read"
    )

    craft_url = s3obj.public_url
    @vessel = Vessel.where(player_id: player.id).first_or_create(craft_url: craft_url)
    if @vessel.craft_url != craft_url
      @vessel.craft_url = craft_url
      @vessel.save
    end

    if @vessel.errors.any?
      flash[:error] = @vessel.errors
      redirect_to new_competition_player_path(@competition) and return
    else
      redirect_to competition_players_path(@competition)
    end
  end

  def destroy
    @vessel = Vessel.where(competition_id: @competition.id, player_id: params[:id]).first
    @vessel.destroy
    redirect_to competition_players_path(@competition)
  end

  private

  def assign_competition
    @competition = Competition.find(params[:competition_id])
  end
end
