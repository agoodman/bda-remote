class Vessel < ApplicationRecord
  belongs_to :player
  belongs_to :competition
  has_many :heat_assignments
  has_many :heats, through: :heat_assignments
  has_many :records
  has_many :rankings

  validates :player_id, presence: true
  validates :competition_id, presence: true

  def score
    rankings.last.score rescue nil
  end
end
