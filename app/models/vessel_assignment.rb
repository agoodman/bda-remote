class VesselAssignment < ApplicationRecord
  belongs_to :vessel
  belongs_to :competition

  validates :vessel_id, presence: true
  validates :competition_id, presence: true
end
