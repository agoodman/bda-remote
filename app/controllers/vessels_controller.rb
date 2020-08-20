class VesselsController < AuthenticatedController
  require 'csv'

  before_action :require_session, only: [:new, :create]

  skip_before_action :verify_authenticity_token

  def new
    @vessel = Vessel.new(competition_id: params[:competition_id], player_id: current_user.player.id)
  end

  def create
    s3 = Aws::S3::Client.new
    bucket = s3.list_buckets.find { |e| e.name == ENV['S3_BUCKET'] }.first
    redirect_to new_competition_vessel_path(competition_id: params[:competition_id]) and return if bucket.nil?

    file = params[:file]

    s3obj = bucket.objects[file.original_filename]
    s3obj.write(
      file: params[:file],
      acl: :public_read
    )
    player = current_user.player
    @vessel = Vessel.where(competition_id: params[:competition_id], player_id: player.id).first_or_create(craft_url: s3obj.public_url)
    redirect_to competition_path(params[:competition_id])
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

  def did_assign_collection
    @collection = @collection.where(competition_id: params[:competition_id])
  end
end
