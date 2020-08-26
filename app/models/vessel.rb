class Vessel < ApplicationRecord
  belongs_to :player
  belongs_to :competition
  has_many :heat_assignments
  has_many :heats, through: :heat_assignments
  has_many :records

  validates :player_id, presence: true
  validates :competition_id, presence: true
end
