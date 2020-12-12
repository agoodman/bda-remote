class PartsController < ApplicationController
  include PartLibrary

  skip_before_action :verify_authenticity_token

  def new
  end

  def create
    file = params[:file]

    unless file.original_filename.ends_with?(".cfg")
      flash[:error] = "File must have .cfg extension"
      redirect_to new_part_path and return
    end

    options = KspPart.interpret(file)
    if options.nil?
      flash[:error] = "Failed to extract properties"
      redirect_to new_part_path and return
    end

    @part = Part.where(name: options['name']).first_or_create
    @part.cost = options['cost'].to_f rescue 0
    @part.mass = options['mass'].to_f rescue 0
    @part.save

    respond_to do |format|
      format.json { render json: @part }
    end
  end
end
