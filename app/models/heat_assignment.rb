class HeatAssignment < ApplicationRecord
  belongs_to :heat
  belongs_to :vessel

  validates :heat_id, presence: true
  validates :vessel_id, presence: true
end
