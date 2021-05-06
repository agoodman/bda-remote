class RolesController < AuthenticatedController
  before_action :require_session
  before_action :can_view_roles?, only: :index
  before_action :can_update_roles?, only: [:promote, :demote]

  def index
    @users = User.includes(:player).order("players.name")
  end

  def promote
    @user = User.find(params[:id])
    @user.roles << params[:role]
    @user.save
    redirect_to roles_path
  end

  def demote
    @user = User.find(params[:id])
    @user.roles.delete params[:role]
    @user.save
    redirect_to roles_path
  end

  private

  def can_update_roles?
    redirect_to roles_path unless current_user.has_role? :organizer
  end

  def can_view_roles?
    redirect_to home_path unless current_user.has_any_role? :organizer, :showrunner
  end
end
