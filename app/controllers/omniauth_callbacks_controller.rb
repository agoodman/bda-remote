class OmniauthCallbacksController < Devise::OmniauthCallbacksController
#  skip_before_action :authenticate_user!, only: :google_oauth2

  def google_oauth2
    auth = request.env["omniauth.auth"]
    user = User.where(provider: auth["provider"], uid: auth["uid"])
            .first_or_initialize(email: auth["info"]["email"])
    user.name ||= auth["info"]["name"]
    user.save!

    user.remember_me = true
    sign_in(:user, user)

    # navigate to registration flow if new player
    if user.player.nil?
      redirect_to register_players_path
    else
      redirect_to player_path(user.player)
    end
  end
end

