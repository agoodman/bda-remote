class Competition < ApplicationRecord
  include Armory

  has_many :records
  has_many :heats
  has_many :vessels

  validates :status, presence: true
  validates :stage, presence: true, numericality: { only_integers: true }
  validates :remaining_heats, presence: true, numericality: { only_integers: true }
  validates :name, presence: true

  after_initialize :assign_initial_status
  after_initialize :assign_initial_stage
  after_initialize :assign_initial_remaining_heats

  def status_label
    labels = [
      "pending_submissions",
      "generating_heats",
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

  # business logic

  def start!
    return unless status == 0
    self.status = 1
    self.stage = 0
    self.started_at = Date.new
    self.save!
    generate_heats(self)
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
    zero_index = mods.find_index(0)
    if !zero_index.nil?
      # zero means we can have even heats
      return possibles[zero_index]
    end
    max_mod = mods.max
    return possibles[mods.find_index(max_mod)]
  end
end
