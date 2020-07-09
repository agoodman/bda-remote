class WelcomeController < ApplicationController
  def index
    @competition_ids = Record.pluck(:competition_id).uniq
    @longest_hit = Record.order("distance desc").limit(10)
  end
end
