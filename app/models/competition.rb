class Competition < ApplicationRecord
  include Armory
  include Validation

  belongs_to :user
  has_many :records
  has_many :heats
  has_many :vessels
  has_many :players, through: :vessels
  has_many :rules
  has_many :rankings
  has_one :metric

  validates :user_id, presence: true
  validates :status, presence: true
  validates :stage, presence: true, numericality: { only_integers: true }
  validates :remaining_heats, presence: true, numericality: { only_integers: true }
  validates :remaining_stages, presence: true, numericality: { only_integers: true }
  validates :name, presence: true

  after_initialize :assign_initial_status
  after_initialize :assign_initial_stage
  after_initialize :assign_initial_remaining_heats
  after_initialize :assign_initial_remaining_stages
  after_create :create_default_metric

  scope :open, -> { where(status: 0) }

  def status_label
    labels = [
      "pending_submissions",
      "running_heats",
      "complete"
    ]
    return labels[status] || "corrupted"
  end

  def assign_initial_status
    self.status = 0 if status.nil?
  end

  def assign_initial_stage
    self.stage = 0
  end

  def assign_initial_remaining_heats
    self.remaining_heats = 0
  end

  def assign_initial_remaining_stages
    self.remaining_stages = 1
  end

  def create_default_metric
    Metric.where(competition_id: self.id).first_or_create
  end

  def validation_strategies
    results = []
    rules.each do |rule|
      Rule::strategies.keys.each do |key|
        strategy = Rule::strategies[key]
        if rule.strategy == strategy
          rule_attrs = eval(rule.params)
          results.push("Validation::#{strategy}".constantize.new(rule_attrs))
        end
      end
    end
    return results
  end

  # business logic

  def start!
    return unless status == 0
    self.status = 1
    self.stage = 0
    self.started_at = Date.new
    self.save!
    (0...self.remaining_stages).each do |k|
      generate_heats(self, k)
    end
    self.remaining_heats = self.heats.for_stage(self.stage).not_started.not_ended.count
  end

  def can_start?
    !started? && !running? && vessels.count > 1
  end

  def extend!
    last_stage = heats.map(&:stage).max
    generate_heats(self, last_stage+1, true)
    self.remaining_stages = self.remaining_stages + 1
    self.save!
  end

  def should_generate_heats?
    status == 1 && remaining_heats == 0 && heats.count == 0
  end

  def started?
    !started_at.nil?
  end

  def running?
    !started_at.nil? && ended_at.nil?
  end

  def generate_heats!
    return unless status == 1 && remaining_heats == 0
    self.remaining_heats = 1
    self.save!
  end

  def players_per_heat
    possibles = Array(5..8)
    vessel_count = vessels.count
    mods = possibles.map { |e| vessel_count % e }
    zero_index = mods.reverse.find_index(0)
    if !zero_index.nil?
      # zero means we can have even heats
      return possibles.reverse[zero_index]
    end
    max_mod = mods.max
    return possibles[mods.find_index(max_mod)]
  end

  def has_remaining_heats?(stage)
    heats.where(stage: stage, started_at: nil, ended_at: nil).any?
  end

  def next_stage
    new_stage = self.stage + 1
    self.stage = new_stage
    self.remaining_heats = heats.where(stage: new_stage, started_at: nil, ended_at: nil).count
    self.save!
  end

  def has_vessel_for(user)
    return false if user.nil?
    return false if user.player.nil?
    return false if vessels.empty?
    return vessels.where(player_id: user.player.id).empty?
  end

  def vessel_for(user)
    return nil if user.nil?
    return nil if user.player.nil?
    return vessels.where(player_id: user.player.id).first
  end

  def leaders
    Rails.cache.fetch("rankings-#{id}") do
      rankings.includes(vessel: :player).order(:rank)
    end
  end

  def update_rankings!
    unordered_rankings = records.includes(vessel: :player).group_by(&:vessel_id).map do |vessel_id,r|
      ranking = rankings.where(vessel_id: vessel_id).first
      if ranking.nil?
        ranking = Ranking.new
        ranking.competition_id = id
        ranking.vessel_id = vessel_id
      end
      ranking.kills = r.map(&:kills).sum
      ranking.deaths = r.map(&:deaths).sum
      ranking.assists = r.map(&:assists).sum
      ranking.hits_out = r.map(&:hits_out).sum
      ranking.hits_in = r.map(&:hits_in).sum
      ranking.dmg_out = r.map(&:dmg_out).sum
      ranking.dmg_in = r.map(&:dmg_in).sum
      ranking.score = metric.score_for_record(ranking)
      ranking.rank = 0
      ranking
    end
    sorted_rankings = unordered_rankings.sort_by { |e| e.score }.reverse
    sorted_rankings.each_with_index do |e, k|
      e.rank = k + 1
      e.save!
    end
    return
  end
end
