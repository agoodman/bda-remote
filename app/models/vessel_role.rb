class VesselRole < ApplicationRecord
  belongs_to :competition

  validates :competition_id, presence: true
  validates :name, presence: true
end
