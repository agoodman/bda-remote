class Ruleset < ApplicationRecord
  has_many :rules
  has_many :competitions
  has_many :vessel_assignments, through: :competitions
  has_many :vessels, through: :vessel_assignments

  validates :name, presence: true
  validates :summary, presence: true
end
