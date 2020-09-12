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

  after_initialize :assign_defaults

  def assign_defaults
    self.kills = 3 if kills.nil?
    self.deaths = -3 if deaths.nil?
    self.assists = 1 if assists.nil?
    self.hits_out = 0 if hits_out.nil?
    self.hits_in = 0 if hits_in.nil?
    self.dmg_out = 0 if dmg_out.nil?
    self.dmg_in = 0 if dmg_in.nil?
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
    return result
  end
end
