class VesselsController < ApplicationController
  include Serviceable
  skip_before_action :verify_authenticity_token
  acts_as_service :vessel, only: [:index, :show, :create, :update]

  def did_assign_collection
    @collection = @collection.where(competition_id: params[:competition_id])
  end
end
