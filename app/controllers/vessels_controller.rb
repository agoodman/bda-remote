class VesselsController < ApplicationController
  include Serviceable
  require 'csv'

  skip_before_action :verify_authenticity_token
  acts_as_service :vessel, only: :index

  def new
  end

  def batch
    c = Competition.find(params[:competition_id])
    items = []
    CSV.foreach(params[:upload], headers: true) do |row|
      p = Player.where(name: row['player_name']).first_or_create
      items << { player_id: p.id, craft_url: row['craft_url'], competition_id: c.id }
    end
    Vessel.import(items)
    head :ok
  end

  def did_assign_collection
    @collection = @collection.where(competition_id: params[:competition_id])
  end
end
