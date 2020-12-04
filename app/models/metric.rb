class Metric < ApplicationRecord
  belongs_to :competition

  validates :competition_id, presence: true
  validates :kills, presence: true, numericality: true
  validates :deaths, presence: true, numericality: true
  validates :assists, presence: true, numericality: true
  validates :hits_out, presence: true, numericality: true
  validates :hits_in, presence: true, numericality: true
  validates :dmg_out, presence: true, numericality: true
  validates :dmg_in, presence: true, numericality: true
  validates :ram_parts_in, presence: true, numericality: true
  validates :ram_parts_out, presence: true, numericality: true
  validates :mis_parts_in, presence: true, numericality: true
  validates :mis_parts_out, presence: true, numericality: true
  validates :mis_dmg_in, presence: true, numericality: true
  validates :mis_dmg_out, presence: true, numericality: true
  validates :death_order, presence: true, numericality: true
  validates :death_time, presence: true, numericality: true
  validates :wins, presence: true, numericality: true

  after_initialize :assign_defaults

  def assign_defaults
    self.kills = 3 if kills.nil?
    self.deaths = -3 if deaths.nil?
    self.assists = 1 if assists.nil?
    self.hits_out = 0 if hits_out.nil?
    self.hits_in = 0 if hits_in.nil?
    self.dmg_out = 0 if dmg_out.nil?
    self.dmg_in = 0 if dmg_in.nil?
    self.ram_parts_in = 0 if ram_parts_in.nil?
    self.ram_parts_out = 0 if ram_parts_out.nil?
    self.mis_parts_in = 0 if mis_parts_in.nil?
    self.mis_parts_out = 0 if mis_parts_out.nil?
    self.mis_dmg_in = 0 if mis_dmg_in.nil?
    self.mis_dmg_out = 0 if mis_dmg_out.nil?
    self.death_order = 0 if death_order.nil?
    self.death_time = 0 if death_time.nil?
    self.wins = 0 if wins.nil?
  end

  def score_for_record(record)
    result = 0
    result += record.kills*self.kills
    result += record.deaths*self.deaths
    result += record.assists*self.assists
    result += record.hits_out*self.hits_out
    result += record.hits_in*self.hits_in
    result += record.dmg_out*self.dmg_out
    result += record.dmg_in*self.dmg_in
    result += record.ram_parts_in*self.ram_parts_in
    result += record.ram_parts_out*self.ram_parts_out
    result += record.mis_parts_in*self.mis_parts_in
    result += record.mis_parts_out*self.mis_parts_out
    result += record.mis_dmg_in*self.mis_dmg_in
    result += record.mis_dmg_out*self.mis_dmg_out
    result += record.death_order*self.death_order
    result += record.death_time*self.death_time
    result += record.wins*self.wins
    return result
  end
end
