class WelcomeController < ApplicationController
  def index
    @longest_hit = Record.order("distance desc").limit(10)
  end
end
