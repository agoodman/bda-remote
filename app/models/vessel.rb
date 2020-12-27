class Vessel < ApplicationRecord
  belongs_to :player
  has_many :vessel_assignments
  has_many :competitions, through: :vessel_assignments
  has_many :heat_assignments
  has_many :heats, through: :heat_assignments
  has_many :records
  has_many :rankings

  validates :player_id, presence: true
  validates :craft_url, presence: true

  def score
    rankings.last.score rescue nil
  end

  def filename
    craft_url.split("/").last rescue "unk"
  end
end
