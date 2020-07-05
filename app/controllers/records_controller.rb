class RecordsController < ApplicationController
  include Serviceable
  skip_before_action :verify_authenticity_token
  acts_as_service :record
end
