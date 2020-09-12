class Ranking < ApplicationRecord
  belongs_to :competition
  belongs_to :vessel

  validates :competition_id, presence: true
  validates :vessel_id, presence: true
  validates :rank, presence: true, numericality: { only_integers: true }
  validates :score, presence: true, numericality: true
  validates :kills, presence: true, numericality: { only_integers: true }
  validates :deaths, presence: true, numericality: { only_integers: true }
  validates :assists, presence: true, numericality: { only_integers: true }
  validates :hits_out, presence: true, numericality: { only_integers: true }
  validates :hits_in, presence: true, numericality: { only_integers: true }
  validates :dmg_out, presence: true, numericality: true
  validates :dmg_in, presence: true, numericality: true

  before_save :assign_defaults

  def assign_defaults
    self.kills = 0 if kills.nil?
    self.deaths = 0 if deaths.nil?
    self.assists = 0 if assists.nil?
    self.hits_out = 0 if hits_out.nil?
    self.hits_in = 0 if hits_in.nil?
    self.dmg_out = 0 if dmg_out.nil?
    self.dmg_in = 0 if dmg_in.nil?
    self.score = 0 if score.nil?
    self.rank = 0 if rank.nil?
  end
end
