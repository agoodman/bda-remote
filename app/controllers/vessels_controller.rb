class VesselsController < AuthenticatedController
  require 'csv'
  include Craft

  before_action :require_session, only: [:new, :create]

  skip_before_action :verify_authenticity_token

  def new
    @vessel = Vessel.new(competition_id: params[:competition_id], player_id: current_user.player.id)
  end

  def create
    # s3 = Aws::S3::Resource.new(region: ENV['AWS_REGION'])
    # bucket = s3.bucket(ENV['S3_BUCKET'])
    # redirect_to new_competition_vessel_path(competition_id: params[:competition_id]) and return if bucket.nil?

    file = params[:file]

    comp = Competition.find(params[:competition_id])
    unless comp.status == 0
      flash[:error] = "Competition is not accepting players"
      redirect_to competition_path(comp) and return
    end

    unless file.original_filename.ends_with?(".craft")
      flash[:error] = "File must have .craft extension"
      redirect_to new_competition_vessel_path(competition_id: params[:competition_id]) and return
    end

    if file.size > 5242880
      flash[:error] = "File too large (max 5MB)"
      redirect_to new_competition_vessel_path(competition_id: params[:competition_id]) and return
    end

    unless is_craft_file_valid?(file, comp.validation_strategies)
      redirect_to new_competition_vessel_path(competition_id: params[:competition_id]) and return
    end

    player = current_user.player
    filename = "#{comp.id}/#{player.id}/#{file.original_filename}"
    s3obj = bucket.object(filename)
    s3obj.put(
      body: file,
      acl: "public-read"
    )
    @vessel = Vessel.where(competition_id: comp.id, player_id: player.id).first_or_create(craft_url: s3obj.public_url)
    redirect_to competition_path(comp)
  end

  def upload
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

  def detail
    file = params[:file]
    @craft = Craft::KspVessel.interpret(file)
  end

  def evaluate
  end

  def did_assign_collection
    @collection = @collection.where(competition_id: params[:competition_id])
  end
end
