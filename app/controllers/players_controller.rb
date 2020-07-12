class PlayersController < ApplicationController
  include Serviceable
  skip_before_action :verify_authenticity_token
  acts_as_service :player, only: :index

  rescue_from ActiveRecord::RecordNotUnique, with: :duplicate_record
  rescue_from ActiveModel::ForbiddenAttributesError, with: :bad_request

  def player_params
    require(:player).permit(:name)
  end

  private

  def duplicate_record_attribute
    :name
  end
end
