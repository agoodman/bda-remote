class Record < ApplicationRecord
  belongs_to :competition
  belongs_to :vessel
  belongs_to :heat

  validates :competition_id, presence: true
  validates :vessel_id, presence: true
  validates :heat_id, presence: true
  validates :assists, numericality: { only_integer: true }
  validates :hits, numericality: { only_integer: true }
  validates :kills, numericality: { only_integer: true }
  validates :deaths, numericality: { only_integer: true }

  after_initialize :assign_defaults

  def player
    vessel.player
  end

  def assign_defaults
    assists = 0 if assists.nil?
    hits = 0 if hits.nil?
    kills = 0 if kills.nil?
    deaths = 0 if deaths.nil?
  end
end
