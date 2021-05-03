class VariantGroup < ApplicationRecord
  include VariantEngine

  belongs_to :evolution
  has_many :variants
  has_one :variant_group_assignment
  has_one :competition, through: :variant_group_assignment

  validates :evolution_id, presence: true
  validates :keys, presence: true
  validates :baseline_values, presence: true
  validates :generation, presence: true, numericality: { only_integer: true }
  validates :selection_strategy, presence: true
  validates :spread_factor, presence: true, numericality: true

  after_create :generate_variants

  attr_accessor :reference_type

  def generate_competition!
    return unless variant_group_assignment.nil?
    c = Competition.create(name: "#{evolution.name}-G#{generation}", user_id: evolution.user_id, max_stages: 15)
    variants.each do |v|
      VesselAssignment.create(vessel_id: v.vessel.id, competition_id: c.id)
    end
    VariantGroupAssignment.create(variant_group_id: id, competition_id: c.id)
  end

  def generate_variants
    case generation_strategy.to_sym
    when :spread
      SpreadTensorVariantStrategy.new.apply!(self)
    when :genetic
      GeneticVariantStrategy.new.apply!(self)
    end
  end

  def result_values
    puts "No competition" and return nil if competition.nil?
    puts "No rankings" and return nil if competition.rankings.empty?
    if selection_strategy == "best"
      # select top ranked vessel variant
      competition.rankings.order(:rank).first.vessel.variant.values
    elsif selection_strategy == "weighted"
      # compute weighted centroid
      rankings = competition.rankings.includes(:vessel => :variant)
      max_score = rankings.map(&:score).max.to_f
      # puts "max score: #{max_score}, variant count: #{variant_count}"
      weighted_values = keys.split(",").map.with_index do |key,index|
        norm_factor = rankings.map { |e| e.score.to_f / max_score }.sum
        (1.0 / norm_factor) * rankings.map { |e|
          # norm_score = e.score.to_f / max_score
          # puts "normalized weight: #{norm_score}, value: #{e.vessel.variant.values.split(",")[index].to_f}"
          (e.score.to_f / max_score) * e.vessel.variant.values.split(",")[index].to_f rescue 0
        }.sum
      end
      weighted_values.join(",")
    else
      return nil
    end
  end
end
