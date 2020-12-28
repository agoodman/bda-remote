class Ruleset < ApplicationRecord
  has_many :rules

  validates :name, presence: true
  validates :summary, presence: true
end
