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
    baseline_values = [
        [5, 10, 5],
        [0.25, 0.5, 0.75],
        [2, 4, 6]
    ]
    vg = variant_groups.create(keys: baseline_keys.join(","), generation: 0)
    (0...3).each do |x|
      (0...3).each do |y|
        (0...3).each do |z|
          variant_values = [
              baseline_values[0][x],
              baseline_values[1][y],
              baseline_values[2][z]
          ]
          vg.variants.create(values: variant_values.map(&:to_s).join(","))
        end
      end
    end

    vg.generate_competition!
  end

  def latest_vessel
    return vessel # override for now
    # return vessel if variant_groups.empty?
    # variant_groups.last.competition.rankings.something?
  end
end
