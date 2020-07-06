class RecordsController < ApplicationController
  include Serviceable
  skip_before_action :verify_authenticity_token
  acts_as_service :record

  def batch
    @records = params['records']
    if @records.count > 100
      head :bad_request && return
    end
    @records.each do |p|
      rp = record_params(p)
      next unless rp
      e = Record.new(rp)
      e.save
    end
  end

  def record_params(input)
    input.permit(:player, :competition_id, :hits, :kills, :deaths, :distance, :weapon)
  end
end
