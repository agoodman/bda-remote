class WelcomeController < ApplicationController
  def index
  end

  def register
  end

  def stats
    records = Record.where('distance > 0').where('weapon is not null')
    @longest_hits = Hash[records.distinct.pluck(:weapon).map { |e| [e, records.where(weapon: e).maximum(:distance)] }].compact
  end

  def logout
    sign_out and redirect_to home_path
  end
end
