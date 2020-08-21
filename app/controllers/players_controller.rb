class PlayersController < AuthenticatedController
#  include Serviceable
  skip_before_action :verify_authenticity_token
#  acts_as_service :player, only: :index

  before_action :require_session, only: [:edit, :update, :register]
  before_action :assign_player, only: [:show, :edit, :update]

  rescue_from ActiveRecord::RecordNotUnique, with: :duplicate_record
#  rescue_from ActiveModel::ForbiddenAttributesError, with: :bad_request

  def player_params
    require(:player).permit(:name)
  end

  def register
    @player = Player.new(user_id: current_user.id)
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

  private

  def assign_player
    @player = Player.find(params[:id])
  end

  def duplicate_record_attribute
    :name
  end
end
