class Record < ApplicationRecord
  belongs_to :competition
  belongs_to :vessel
  belongs_to :heat

  validates :competition_id, presence: true
  validates :vessel_id, presence: true
  validates :heat_id, presence: true
  validates :hits_out, numericality: { only_integer: true }
  validates :hits_in, numericality: { only_integer: true }
  validates :dmg_out, numericality: true
  validates :dmg_in, numericality: true
  validates :kills, numericality: { only_integer: true }
  validates :deaths, numericality: { only_integer: true }
  validates :assists, numericality: { only_integer: true }
  validates :wins, numericality: { only_integer: true }
  validates :death_time, numericality: true
  validates :death_order, numericality: true
  validates :mis_dmg_out, numericality: true
  validates :mis_dmg_in, numericality: true
  validates :mis_parts_out, numericality: { only_integer: true }
  validates :mis_parts_in, numericality: { only_integer: true }
  validates :ram_parts_out, numericality: { only_integer: true }
  validates :ram_parts_in, numericality: { only_integer: true }
  validates :roc_parts_out, presence: true, numericality: { only_integers: true }
  validates :roc_parts_in, presence: true, numericality: { only_integers: true }
  validates :roc_dmg_out, presence: true, numericality: true
  validates :roc_dmg_in, presence: true, numericality: true
  validates :waypoints, presence: true, numericality: { only_integers: true }
  validates :elapsed_time, presence: true, numericality: true
  validates :deviation, presence: true, numericality: true
  validates :ast_parts_in, presence: true, numericality: true

  before_validation :assign_defaults

  def player
    vessel.player
  end

  def assign_defaults
    self.hits_out = 0 if hits_out.nil?
    self.hits_in = 0 if hits_in.nil?
    self.dmg_out = 0 if dmg_out.nil?
    self.dmg_in = 0 if dmg_in.nil?
    self.kills = 0 if kills.nil?
    self.deaths = 0 if deaths.nil?
    self.assists = 0 if assists.nil?
    self.wins = 0 if wins.nil?
    self.death_time = 0 if death_time.nil?
    self.death_order = 0 if death_order.nil?
    self.mis_dmg_out = 0 if mis_dmg_out.nil?
    self.mis_dmg_in = 0 if mis_dmg_in.nil?
    self.mis_parts_out = 0 if mis_parts_out.nil?
    self.mis_parts_in = 0 if mis_parts_in.nil?
    self.ram_parts_out = 0 if ram_parts_out.nil?
    self.ram_parts_in = 0 if ram_parts_in.nil?
    self.roc_dmg_out = 0 if roc_dmg_out.nil?
    self.roc_dmg_in = 0 if roc_dmg_in.nil?
    self.roc_parts_out = 0 if roc_parts_out.nil?
    self.roc_parts_in = 0 if roc_parts_in.nil?
    self.waypoints = 0 if waypoints.nil?
    self.elapsed_time = 0 if elapsed_time.nil?
    self.deviation = 0 if deviation.nil?
    self.ast_parts_in = 0 if ast_parts_in.nil?
  end
end
