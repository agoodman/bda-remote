class PlayersController < AuthenticatedController
#  include Serviceable
  include ActiveRecordExtensions
  skip_before_action :verify_authenticity_token
#  acts_as_service :player, only: :index

  before_action :require_session, only: [:edit, :update, :register]
  before_action :assign_player, only: [:show, :edit, :update]
  before_action :check_existing, only: :register

  rescue_from ActiveRecord::RecordNotUnique, with: :duplicate_record
#  rescue_from ActiveModel::ForbiddenAttributesError, with: :bad_request

  def player_params
    require(:player).permit(:name)
  end

  def register
    @player = Player.new(user_id: current_user.id)
  end

  def create
    if Player.exists?(name: params[:player][:name])
      flash[:error] = "Player name already exists! Please choose a different one."
      redirect_to register_players_path and return
    end
    @player = Player.create(user_id: current_user.id, name: params[:player][:name])
    redirect_to competitions_path
  end

  def index
    @players = Player.all
  end

  def show
  end

  def edit
  end

  def update
    @player.name = params[:player][:name]
    @player.save
    redirect_to player_path(@player)
  end

  def chart
    reference = Time.at(params[:since] || 0)
    player = Player.find(params[:id])
    records = player.records.order("records.updated_at").limit(1000).where(updated_at: reference..)
    respond_to do |format|
      format.json { render json: records }
    end
  end

  def stats
    respond_to do |format|
      format.html
    end
  end

  def recent
    now = Time.now
    min_date = Time.now - 1.month
    players = Rails.cache.fetch("players") do
      Player.order(:created_at).where("created_at > ?", min_date)
    end


    day_keys, day_counts = buckets_for(players, 30)
    respond_to do |format|
      format.json { render json: { player_buckets: { labels: day_keys, values: day_counts } }, status: :ok }
    end
  end

  private

  def assign_player
    @player = Player.find(params[:id])
  end

  def check_existing
    redirect_to player_path(current_user.player) and return unless current_user.player.nil?
  end

  def duplicate_record_attribute
    :name
  end
end
