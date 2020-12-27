class Ruleset < ApplicationRecord
  has_many :rules

  validates :name, presence: true
end
