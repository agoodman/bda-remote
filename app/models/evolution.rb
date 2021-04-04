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
  after_create :initialize_variant_group

  def assign_max_generations
    self.max_generations = 5 if max_generations.nil?
  end

  def initialize_variant_group
    # baseline group
    baseline_keys = [
        "steerMult",
        "steerKiAdjust",
        "steerDamping"
    ]
    variant_groups.create(keys: baseline_keys.join(","), generation: 0)
  end

  def latest_vessel
    variant_groups.where('generation < ?', variant_groups.count-1).order(:generation).last.competition.rankings.order(:rank).first.vessel rescue vessel
  end
end
