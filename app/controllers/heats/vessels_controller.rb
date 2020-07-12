class Heats::VesselsController < ApplicationController
  include Serviceable
  acts_as_service :vessel, only: :index

  def assign_collection
    @collection = HeatAssignment.where(heat_id: params[:heat_id]).map(&:vessel)
  end
end
