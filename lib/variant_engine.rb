module VariantEngine
  @@selection_strategies = [
      "best",
      "weighted"
  ]

  def selection_strategies
    @@selection_strategies
  end

  module_function :selection_strategies

  class VariantStrategy
  end

  @variant_key_defaults = {
      "steerMult": 6.59999,
      "steerKiAdjust": 0.25,
      "steerDamping": 2.5,
      "DynamicDampingMin": 1.5,
      "DynamicDampingMax": 4,
      "dynamicSteerDampingFactor": 7,
      "DynamicDampingPitchMin": 1.5,
      "DynamicDampingPitchMax": 4,
      "dynamicSteerDampingPitchFactor": 7,
      "DynamicDampingYawMin": 1.5,
      "DynamicDampingYawMax": 4,
      "dynamicSteerDampingYawFactor": 7,
      "DynamicDampingRollMin": 1.5,
      "DynamicDampingRollMax": 4,
      "dynamicSteerDampingRollFactor": 7,
      "minAltitude": 500,
      "maxSpeed": 325,
      "takeOffSpeed": 70,
      "minSpeed": 60,
      "strafingSpeed": 120,
      "idleSpeed": 120,
      "maxSteer": 1,
      "maxSteerAtMaxSpeed": 1,
      "cornerSpeed": 200,
      "maxBank": 180,
      "maxAllowedGForce": 10,
      "maxAllowedAoA": 35,
      "minEvasionTime": 0.200000003,
      "evasionThreshold": 50,
      "evasionTimeThreshold": 0,
      "collisionAvoidanceThreshold": 30,
      "vesselCollisionAvoidancePeriod": 1.5,
      "extendMult": 1,
      "turnRadiusTwiddleFactorMin": 2,
      "turnRadiusTwiddleFactorMax": 4
  }

  class SpreadTensorVariantStrategy < VariantStrategy
    @@variant_key_clamps = {
        "steerMult": [0.1, 20],
        "steerKiAdjust": [0.01, 1],
        "steerDamping": [1, 8],
        "DynamicDampingMin": [1, 8],
        "DynamicDampingMax": [1, 8],
        "dynamicSteerDampingFactor": [0.1, 10],
        "DynamicDampingPitchMin": [1, 8],
        "DynamicDampingPitchMax": [1, 8],
        "dynamicSteerDampingPitchFactor": [0.1, 10],
        "DynamicDampingYawMin": [1, 8],
        "DynamicDampingYawMax": [1, 8],
        "dynamicSteerDampingYawFactor": [0.1, 10],
        "DynamicDampingRollMin": [1, 8],
        "DynamicDampingRollMax": [1, 8],
        "dynamicSteerDampingRollFactor": [0.1, 10],
        "defaultAltitude": [150, 15000],
        "minAltitude": [25, 6000],
        "maxSpeed": [20, 800],
        "takeOffSpeed": [10, 200],
        "minSpeed": [10, 200],
        "strafingSpeed": [10, 200],
        "idleSpeed": [10, 200],
        "maxSteer": [0.1, 1],
        "maxSteerAtMaxSpeed": [0.1, 1],
        "cornerSpeed": [10, 200],
        "maxBank": [10, 180],
        "maxAllowedGForce": [2, 45],
        "maxAllowedAoA": [0, 80],
        "minEvasionTime": [0, 1],
        "evasionThreshold": [0, 100],
        "evasionTimeThreshold": [0, 1],
        "collisionAvoidanceThreshold": [0, 50],
        "vesselCollisionAvoidancePeriod": [0, 3],
        "extendMult": [0, 2],
        "turnRadiusTwiddleFactorMin": [1, 5],
        "turnRadiusTwiddleFactorMax": [1, 5]
    }

    def apply!(variant_group)
      spread_factor = 0.25 / (variant_group.generation+1) rescue 0.25

      keys = variant_group.keys.split(",") rescue []
      return unless keys.count == 3

      previous_variant_group = variant_group.evolution.variant_groups.where('generation < ?', variant_group.generation).order(:generation).last
      if previous_variant_group.nil?
        # initial baseline
        centers = keys.map do |k|
          clamps = @@variant_key_clamps[k.to_sym]
          (clamps[0] + clamps[1]) / 2.0
        end
      else
        # use values from top ranked variant from previous group
        centers = previous_variant_group.competition.rankings.order(:rank).first.vessel.variant.values.split(",") rescue []
      end
      return unless centers.count == 3

      values = keys.map.with_index do |k,index|
        clamps = @@variant_key_clamps[k.to_sym]
        center = centers[index].to_f
        span = clamps[1] - clamps[0]
        [center - spread_factor * span, center, center + spread_factor * span]
      end

      (0...3).each do |x|
        (0...3).each do |y|
          (0...3).each do |z|
            variant_values = [
                values[0][x],
                values[1][y],
                values[2][z]
            ]
            variant_group.variants.create(values: variant_values.map(&:to_s).join(","))
          end
        end
      end

      variant_group.generate_competition!
    end
  end
end
