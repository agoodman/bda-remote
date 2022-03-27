class WelcomeController < ApplicationController
  def index
  end

  def register
  end

  def stats
    @longest_hits = Hash[Record.distinct.pluck(:weapon).map { |e| [e, Record.where(weapon: e).maximum(:distance)] }].compact
  end

  def logout
    sign_out and redirect_to home_path
  end
end
