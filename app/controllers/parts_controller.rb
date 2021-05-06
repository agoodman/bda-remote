class PartsController < AuthenticatedController
  include PartLibrary

  skip_before_action :verify_authenticity_token

  before_action :require_session, only: [:index, :edit, :update]
  before_action :assign_part_by_name, only: :show
  before_action :assign_part, only: [:edit, :update]
  before_action :reject_unauthorized, only: [:edit, :update]

  def index
    @parts = Part.order(:name)
  end

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

  def show
    head :bad_request and return if @part.nil?
    respond_to do |format|
      format.json { render json: @part, status: :ok }
    end
  end

  def edit
  end

  def update
    @part.points = params[:part][:points]
    @part.save
    if @part.errors.any?
      redirect_to edit_part_path(@part)
    else
      redirect_to parts_path
    end
  end

  private

  def assign_part
    @part = Part.find(params[:id])
  end

  def assign_part_by_name
    @part = Part.where(name: params[:id]).first
  end

  def reject_unauthorized
    redirect_to home_path unless current_user.can_write_parts?
  end
end
