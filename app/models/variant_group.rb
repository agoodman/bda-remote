class VariantGroup < ApplicationRecord
  include VariantEngine

  belongs_to :evolution
  has_many :variants
  has_one :variant_group_assignment
  has_one :competition, through: :variant_group_assignment

  validates :evolution_id, presence: true
  validates :keys, presence: true
  validates :generation, presence: true, numericality: { only_integer: true }

  after_create :generate_variants

  def generate_competition!
    return unless variant_group_assignment.nil?
    c = Competition.create(name: "#{evolution.name}-G#{generation}", user_id: evolution.user_id, max_stages: 40)
    variants.each do |v|
      VesselAssignment.create(vessel_id: v.vessel.id, competition_id: c.id)
    end
    VariantGroupAssignment.create(variant_group_id: id, competition_id: c.id)
  end

  def generate_variants
    SpreadTensorVariantStrategy.new.apply!(self)
  end
end
