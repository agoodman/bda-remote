class ApplicationController < ActionController::Base

  def duplicate_record
    attr = duplicate_record_attribute
    result = { error: attr.humanize + " must be unique" }
    respond_to do |format|
      format.json { render json: result, status: :unprocessible_entity }
      format.xml { render xml: result, status: :unprocessible_entity }
    end
  end

  def bad_request
    result = { error: "Bad request" }
    respond_to do |format|
      format.json { render json: result, status: :bad_request }
      format.xml { render xml: result, status: :bad_request }
    end
  end

end
