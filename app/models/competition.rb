class Competition < ApplicationRecord
  include Armory
  include Validation

  belongs_to :user
  belongs_to :ruleset, optional: true
  has_many :records
  has_many :heats
  has_many :vessel_assignments
  has_many :vessels, through: :vessel_assignments
  has_many :players, through: :vessels
  has_many :rankings
  has_one :metric
  has_one :variant_group_assignment
  has_many :organizers

  validates :user_id, presence: true
  validates :status, presence: true
  validates :stage, presence: true, numericality: { only_integers: true }
  validates :remaining_heats, presence: true, numericality: { only_integers: true }
  validates :max_stages, presence: true, numericality: { only_integers: true }
  validates :max_vessels_per_player, presence: true, numericality: { only_integers: true }
  validates :name, presence: true, length: { minimum: 4, maximum: 150 }
  validates :secret_key, presence: true

  after_initialize :assign_initial_status
  after_initialize :assign_initial_stage
  after_initialize :assign_initial_remaining_heats
  after_initialize :assign_initial_max_stages
  after_initialize :assign_initial_max_players_per_heat
  after_initialize :assign_initial_mode
  after_create :create_default_metric

  scope :available, -> { where(status: 0) }
  scope :unpublished, -> { where('published_at is null') }
  scope :published, -> { where('published_at is not null') }

  @@modes = {ffa: "Free For All", path: "Waypoint Path", chase: "Chase"}
  def self.modes
    @@modes.keys.map { |k| [@@modes[k], k] }
  end

  def display_mode
    @@modes[(mode.to_sym || :ffa)]
  end

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
    self.stage = 0 if stage.nil?
  end

  def assign_initial_remaining_heats
    self.remaining_heats = 0
  end

  def assign_initial_max_stages
    self.max_stages = 1 if max_stages.nil?
  end

  def assign_initial_max_players_per_heat
    self.max_players_per_heat = 8 if max_players_per_heat.nil?
  end

  def assign_initial_mode
    self.mode = "ffa" if mode.nil?
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

  def rules
    ruleset.rules rescue []
  end

  # business logic

  def start!
    return unless status == 0
    self.status = 1
    self.stage = 0
    self.started_at = Date.new
    self.save!
    strategy = select_strategy
    generate_heats(self, 0, strategy)
    self.remaining_heats = self.heats.for_stage(self.stage).not_started.not_ended.count
  end

  def can_start?
    !started? && !running? && vessels.count > 1
  end

  def unstart!
    return unless status == 1
    self.status = 0
    self.started_at = nil
    self.save!
  end

  def extend!(strategy = select_strategy)
    last_stage = heats.map(&:stage).max
    generate_heats(self, last_stage+1, strategy, true)
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

  def user_can_manage?(user)
    return true if user_id == user.id
    organizers.where(user_id: user.id).any?
  end

  def players_per_heat(vessel_count)
    max_players = max(8, min(max_players_per_heat, 20)) rescue 8
    possibles = Array(5..max_players)
    vessel_count = vessels.includes(:player).where(players: { is_human: true }).count unless vessel_count
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
    heats.where(stage: stage, ended_at: nil).any?
  end

  def next_stage
    return if stage >= max_stages
    new_stage = self.stage + 1
    self.stage = new_stage
    unfinished_count = heats.for_stage(new_stage).not_started.not_ended.count
    if unfinished_count == 0
      generate_heats(self, new_stage, select_strategy, true)
      self.remaining_heats = heats.for_stage(new_stage).not_started.not_ended.count
    else
      self.remaining_heats = unfinished_count
    end
    self.save!
  end

  def has_vessel_for(user)
    return false if user.nil?
    return false if user.player.nil?
    return false if vessels.empty?
    return !vessels.where(player_id: user.player.id).empty?
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

  def stability_factor
    last_stage = records.joins(:heat).maximum(:stage) || 0
    if last_stage == 0
      rankings.map(&:rank).sum || 999 rescue 999
    else
      previous_rankings = computed_rankings(last_stage-1)
      current_rankings = computed_rankings(last_stage)
      prev_rank_map = {}
      previous_rankings.each do |e|
        prev_rank_map[e.vessel_id] = e.rank
      end
      curr_rank_map = {}
      current_rankings.each do |e|
        curr_rank_map[e.vessel_id] = e.rank
      end
      rank_changes = prev_rank_map.keys.map do |vid|
        rank_change = curr_rank_map[vid].to_i - prev_rank_map[vid].to_i
        rank_change.abs
      end
      rank_changes.sum.to_f / rank_changes.count.to_f rescue 999
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
      ranking.mis_dmg_out = r.map(&:mis_dmg_out).sum
      ranking.mis_dmg_in = r.map(&:mis_dmg_in).sum
      ranking.mis_parts_out = r.map(&:mis_parts_out).sum
      ranking.mis_parts_in = r.map(&:mis_parts_in).sum
      ranking.ram_parts_out = r.map(&:ram_parts_out).sum
      ranking.ram_parts_in = r.map(&:ram_parts_in).sum
      ranking.roc_dmg_out = r.map(&:roc_dmg_out).sum
      ranking.roc_dmg_in = r.map(&:roc_dmg_in).sum
      ranking.roc_parts_out = r.map(&:roc_parts_out).sum
      ranking.roc_parts_in = r.map(&:roc_parts_in).sum
      ranking.death_order = r.map(&:death_order).sum
      ranking.death_time = r.map(&:death_time).sum
      ranking.wins = r.map(&:wins).sum
      ranking.waypoints = r.map(&:waypoints).sum
      ranking.elapsed_time = r.map(&:elapsed_time).sum
      ranking.deviation = r.map(&:deviation).sum
      ranking.ast_parts_in = r.map(&:ast_parts_in).sum
      ranking.score = metric.score_for_record(ranking)
      ranking.rank = 0
      ranking
    end
    # subtract minimum score to eliminate negative
    min_score = unordered_rankings.map(&:score).min || 0
    sorted_rankings = unordered_rankings.sort_by { |e| e.score }.reverse
    sorted_rankings.each_with_index do |e, k|
      e.rank = k + 1
      e.score = e.score - min_score
      e.save!
    end
    return
  end

  def public?
    !published_at.nil? && published_at < Time.now
  end

  def private?
    published_at.nil?
  end

  def publish!
    self.published_at = Time.now
    self.save!
  end

  def unpublish!
    self.published_at = nil
    self.save!
  end

  private

  def computed_rankings(last_stage)
    unordered_rankings = records.joins(:heat).includes(vessel: :player).where('heats.stage <= ?', last_stage).group_by(&:vessel_id).map do |vessel_id,r|
      ranking = Ranking.new
      ranking.competition_id = id
      ranking.vessel_id = vessel_id
      ranking.kills = r.map(&:kills).sum
      ranking.deaths = r.map(&:deaths).sum
      ranking.assists = r.map(&:assists).sum
      ranking.hits_out = r.map(&:hits_out).sum
      ranking.hits_in = r.map(&:hits_in).sum
      ranking.dmg_out = r.map(&:dmg_out).sum
      ranking.dmg_in = r.map(&:dmg_in).sum
      ranking.mis_dmg_out = r.map(&:mis_dmg_out).sum
      ranking.mis_dmg_in = r.map(&:mis_dmg_in).sum
      ranking.mis_parts_out = r.map(&:mis_parts_out).sum
      ranking.mis_parts_in = r.map(&:mis_parts_in).sum
      ranking.ram_parts_out = r.map(&:ram_parts_out).sum
      ranking.ram_parts_in = r.map(&:ram_parts_in).sum
      ranking.roc_dmg_out = r.map(&:roc_dmg_out).sum
      ranking.roc_dmg_in = r.map(&:roc_dmg_in).sum
      ranking.roc_parts_out = r.map(&:roc_parts_out).sum
      ranking.roc_parts_in = r.map(&:roc_parts_in).sum
      ranking.death_order = r.map(&:death_order).sum
      ranking.death_time = r.map(&:death_time).sum
      ranking.wins = r.map(&:wins).sum rescue 0
      ranking.waypoints = r.map(&:waypoints).sum
      ranking.elapsed_time = r.map(&:elapsed_time).sum
      ranking.deviation = r.map(&:deviation).sum
      ranking.ast_parts_in = r.map(&:ast_parts_in).sum
      ranking.score = metric.score_for_record(ranking)
      ranking.rank = 0
      ranking
    end
    min_score = unordered_rankings.map(&:score).min || 0
    sorted_rankings = unordered_rankings.sort_by { |e| e.score }.reverse
    sorted_rankings.each_with_index do |e, k|
      e.rank = k + 1
      e.score = e.score - min_score
      e
    end
  end

  def select_strategy
    case mode.to_sym
    when :path
      SinglePlayerStrategy.new
    when :chase
      SinglePlayerStrategy.new
    when :ffa
      if stage > 0
        TournamentRankingStrategy.new
      else
        RandomDistributionStrategy.new
      end
    else
      TournamentRankingStrategy.new
    end
  end
end
