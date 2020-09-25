class Record < ApplicationRecord
  belongs_to :competition
  belongs_to :vessel
  belongs_to :heat

  validates :competition_id, presence: true
  validates :vessel_id, presence: true
  validates :heat_id, presence: true
  validates :hits_out, numericality: { only_integer: true }
  validates :hits_in, numericality: { only_integer: true }
  validates :dmg_out, numericality: true
  validates :dmg_in, numericality: true
  validates :kills, numericality: { only_integer: true }
  validates :deaths, numericality: { only_integer: true }
  validates :assists, numericality: { only_integer: true }
  validates :mis_dmg_out, numericality: true
  validates :mis_dmg_in, numericality: true
  validates :mis_parts_out, numericality: { only_integer: true }
  validates :mis_parts_in, numericality: { only_integer: true }
  validates :ram_parts_out, numericality: { only_integer: true }
  validates :ram_parts_in, numericality: { only_integer: true }

  after_initialize :assign_defaults

  def player
    vessel.player
  end

  def assign_defaults
    hits_out = 0 if hits_out.nil?
    hits_in = 0 if hits_in.nil?
    dmg_out = 0 if dmg_out.nil?
    dmg_in = 0 if dmg_in.nil?
    kills = 0 if kills.nil?
    deaths = 0 if deaths.nil?
    assists = 0 if assists.nil?
    mis_dmg_out = 0 if mis_dmg_out.nil?
    mis_dmg_in = 0 if mis_dmg_in.nil?
    mis_parts_out = 0 if mis_parts_out.nil?
    mis_parts_in = 0 if mis_parts_in.nil?
    ram_parts_out = 0 if ram_parts_out.nil?
    ram_parts_in = 0 if ram_parts_in.nil?
  end
end
