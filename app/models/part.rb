class Part < ApplicationRecord
  validates :name, presence: true
  validates :cost, presence: true, numericality: true
  validates :mass, presence: true, numericality: true
end
