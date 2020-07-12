class WelcomeController < ApplicationController
  def index
    @competitions = Competition.order("updated_at desc").limit(20)
    @longest_hit = Record.order("distance desc").limit(10)
  end
end
