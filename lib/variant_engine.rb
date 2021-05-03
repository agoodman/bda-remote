module VariantEngine
  require "open-uri"

  @@generation_strategies = [
      "spread",
      "genetic"
  ]

  @@selection_strategies = [
      "best",
      "weighted"
  ]

  def generation_strategies
    @@generation_strategies
  end

  def selection_strategies
    @@selection_strategies
  end

  def all_keys
    @@variant_key_defaults.keys
  end

  def reference_values_for(craft_url, keys)
    puts "fetching #{craft_url}"
    craft_file = URI::open(craft_url).read rescue nil
    return nil if craft_file.nil?
    remaining_keys = {}
    keys.each { |key| remaining_keys[key] = 1 }

    existing_values_map = {}
    craft_file.lines.each do |line|
      key_to_remove = nil
      remaining_keys.keys.each do |key|
        pattern = /^.*#{key} = (.+)$/
        value = line.match(pattern)[1] rescue nil
        unless value.nil?
          existing_values_map[key] = value.strip
          key_to_remove = key
          break
        end
      end
      unless key_to_remove.nil?
        remaining_keys[key_to_remove] = nil
      end
    end
    existing_values_map.values.join(",")
  end

  module_function :generation_strategies
  module_function :selection_strategies
  module_function :all_keys
  module_function :reference_values_for

  class VariantStrategy
  end

  @@variant_key_defaults = {
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
      spread_factor = variant_group.spread_factor

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

  class GeneticVariantStrategy < VariantStrategy
    def apply!(variant_group)
      # 10% random mutation factor
      mutation_factor = 0.1
      if true || variant_group.generation == 0
        # for first group, generate 6 random mutation pairs
        # pick three random axes
        axes = []
        available_axes = variant_group.keys.split(",")
        3.times do
          next_axis = available_axes[rand*available_axes.count]
          available_axes -= [next_axis]
          axes.push(next_axis)
        end

        variant_group.variants.create(values: variant_group.baseline_values)
        axes.each do |axis|
          offset = rand * mutation_factor
          generate_dipole(variant_group, axis, offset, variant_group.baseline_values)
        end
      else
        # drop two worst and generate random mutation dipole from best variant
        previous_group = variant_group.evolution.variant_groups.where('generation < ?', variant_group.generation).order(:generation).first
        return if previous_group.nil? || previous_group.competition.nil?
        rankings = previous_group.competition.rankings.includes(vessel: :variant).order(:rank)
        retained_count = rankings.count - 2
        retained_variants = rankings.take(retained_count).map(&:vessel).map(&:variant)
        retained_variants.each do |v|
          variant_group.variants.create(values: v.values)
        end

        # pick a random mutation axis based on the best variant
        group_keys = variant_group.keys.split(",")
        axis = group_keys[rand*group_keys.count]
        offset = rand * mutation_factor

        generate_dipole(variant_group, axis, offset, retained_variants.first.values)
      end

      variant_group.generate_competition!
    end

    def generate_dipole_values(keys, values, axis, magnitude)
      index = keys.index(axis)
      if index.nil?
        puts "found no match for #{axis} in #{keys}"
      else
        puts "matching index #{index}"
      end
      [-1, 1].map do |modifier|
        values.map.with_index do |e,k|
          if k == index
            e.to_f * (1.0 + magnitude * modifier).to_f
          else
            e.to_f
          end
        end
      end
    end

    def generate_dipole(variant_group, axis, offset, reference_values)
      puts "generate dipole: #{axis}, #{offset}"
      generate_dipole_values(variant_group.keys.split(","), reference_values.split(","), axis, offset).each do |values|
        variant_group.variants.create(values: values.join(","))
      end
    end
  end

end
