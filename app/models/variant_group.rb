class VariantGroup < ApplicationRecord
  belongs_to :evolution
  has_many :variants
  has_one :variant_group_assignment
  has_one :competition, through: :variant_group_assignment

  validates :evolution_id, presence: true
  validates :keys, presence: true
  validates :generation, presence: true, numericality: { only_integer: true }

  def generate_competition!
    return unless variant_group_assignment.nil?
    c = Competition.create(name: "#{evolution.name}-G#{generation}", user_id: evolution.user_id)
    variants.each do |v|
      VesselAssignment.create(vessel_id: v.vessel.id, competition_id: c.id)
    end
    VariantGroupAssignment.create(variant_group_id: id, competition_id: c.id)
  end
end
