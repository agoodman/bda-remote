class Vessel < ApplicationRecord
  include Discard::Model

  belongs_to :player
  has_many :variant_assignments
  has_many :vessel_assignments
  has_many :competitions, through: :vessel_assignments
  has_many :heat_assignments
  has_many :heats, through: :heat_assignments
  has_many :records
  has_many :rankings

  validates :player_id, presence: true
  validates :craft_url, presence: true
  validates :name, presence: true

  def score
    rankings.last.score rescue nil
  end

  def filename
    craft_url.split("/").last rescue "unk"
  end

  def full_name
    "#{player.name}_#{name}"
  end
end
