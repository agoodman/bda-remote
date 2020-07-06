class WelcomeController < ApplicationController
  def index
    @competition_ids = Record.pluck(:competition_id).uniq
  end
end
