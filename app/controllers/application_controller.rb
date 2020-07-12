class ApplicationController < ActionController::Base

  def duplicate_record
    attr = duplicate_record_attribute
    result = { error: attr.humanize + " must be unique" }
    respond_to do |format|
      format.json { render json: result }
      format.xml { render xml: result }
    end
  end

  def bad_request
    result = { error: "Bad request" }
    respond_to do |format|
      format.json { render json: result }
      format.xml { render xml: result }
    end
  end

end
