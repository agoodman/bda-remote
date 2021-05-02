class Evolution < ApplicationRecord
  belongs_to :user
  belongs_to :vessel
  has_many :variant_groups
  has_many :variants, through: :variant_groups

  validates :user_id, presence: true
  validates :vessel_id, presence: true
  validates :name, presence: true
  validates :max_generations, presence: true, numericality: { only_integer: true }

  after_initialize :assign_max_generations

  def assign_max_generations
    self.max_generations = 5 if max_generations.nil?
  end

  def latest_vessel
    variant_groups.where('generation < ?', variant_groups.count-1).order(:generation).last.competition.rankings.order(:rank).first.vessel rescue vessel
  end
end
