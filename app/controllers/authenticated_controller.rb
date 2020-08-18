class AuthenticatedController < ApplicationController

  def require_session
    redirect_to user_google_oauth2_omniauth_authorize_path and return unless user_signed_in?
  end

end

