class Record < ApplicationRecord
  belongs_to :competition
  belongs_to :vessel
  belongs_to :heat
  belongs_to :player, through: :vessel

  validates :competition_id, presence: true
  validates :vessel_id, presence: true
  validates :heat_id, presence: true
  validates :hits, numericality: { only_integer: true }
  validates :kills, numericality: { only_integer: true }
  validates :deaths, numericality: { only_integer: true }
end
