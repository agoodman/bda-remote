class WelcomeController < ApplicationController
  def index
    @longest_hit = Record.order("distance desc").limit(10)
  end

  def register
  end

  def logout
    sign_out and redirect_to home_path
  end
end
