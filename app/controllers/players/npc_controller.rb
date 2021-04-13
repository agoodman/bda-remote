class Players::NpcController < AuthenticatedController

  before_action :require_session

  def new
    @player = Player.new
  end

  def create
    if Player.where(name: params[:player][:name]).any?
      flash[:error] = "NPC already exists!"
      redirect_to new_npc_path
      return
    end
    @player = Player.create(user_id: 1, name: params[:player][:name], is_human: false)
    redirect_to players_path
  end

end
