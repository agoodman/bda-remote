class Vessel < ApplicationRecord
  include Discard::Model

  belongs_to :player
  has_one :variant_assignment
  has_one :variant, through: :variant_assignment
  has_many :vessel_assignments
  has_many :competitions, through: :vessel_assignments
  has_many :heat_assignments
  has_many :heats, through: :heat_assignments
  has_many :records
  has_many :rankings

  validates :player_id, presence: true
  validates :craft_url, presence: true
  validates :name, presence: true, length: { minimum: 4, maximum: 50 }, format: { with: /\A[a-zA-Z0-9_\-+]+\z/, message: "only letters, numbers, underscore (_), hyphen (-), or plus (+) are allowed" }

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
