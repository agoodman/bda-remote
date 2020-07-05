class Record < ApplicationRecord
  validates :player, presence: true
  validates :hits, numericality: { only_integer: true }
  validates :kills, numericality: { only_integer: true }
  validates :deaths, numericality: { only_integer: true }
end
