class Part < ApplicationRecord
  validates :name, presence: true
  validates :cost, presence: true, numericality: true
  validates :mass, presence: true, numericality: true
  validates :points, presence: true, numericality: true

  before_validation :assign_defaults

  def assign_defaults
    self.cost = 0 if cost.nil?
    self.mass = 0 if mass.nil?
    self.points = 0 if points.nil?
  end
end
