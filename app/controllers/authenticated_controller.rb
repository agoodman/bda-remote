class AuthenticatedController < ApplicationController

  def require_session
    sign_in(User.first) and return if Rails.env.development?
    redirect_to user_google_oauth2_omniauth_authorize_path and return unless user_signed_in?
  end

end

