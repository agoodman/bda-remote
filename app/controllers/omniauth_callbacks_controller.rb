class OmniauthCallbacksController < Devise::OmniauthCallbacksController
#  skip_before_action :authenticate_user!, only: :google_oauth2

  def google_oauth2
    auth = request.env["omniauth.auth"]
    user = User.where(provider: auth["provider"], uid: auth["uid"])
            .first_or_initialize(email: auth["info"]["email"])
    user.name ||= auth["info"]["name"]
    user.save!

    # auto-generate a player
    if user.player.nil?
      Player.create(user_id: user.id, name: user.name)
    end

    user.remember_me = true
    sign_in(:user, user)

    redirect_to player_path
  end
end

