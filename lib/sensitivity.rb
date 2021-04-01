# Sensitivity Analysis Module
#
# Designed to configure a spread of parametric variants from a baseline vessel.
#
module Sensitivity
  include Craft
  require "open-uri"

  def configure(vessel, user)
    # fetch craft file
    craft = URI::open(vessel.craft_url).read
    # craft = URI::open("https://bdascores.s3.amazonaws.com/players/24/aubranium_UglyBox.craft").read

    # generate a spread of parametric craft and associated vessels
    index = 1
    generated_vessels = []
    @available_parameters.each do |p|
      pattern = /^(.*#{p} = )(.+)$/
      @spread_tensor.each do |v|
        # find/replace the matching line from the baseline craft file
        new_craft_lines = craft.lines.map do |line|
          match = line.match(pattern)
          if match.nil?
            line
          else
            result = "#{match[1]}#{match[2].to_f * v}\n"
            # puts "in: #{line}, out[#{v}]: #{result}"
            result
          end
        end
        new_craft = new_craft_lines.join
        new_name = "#{vessel.name}Mk#{index}"
        new_vessel = upload_craft(new_craft, new_name, user.player.id)
        if new_vessel.nil?
          return nil
        end
        generated_vessels.push(new_vessel)
        index = index + 1
      end
    end

    return nil if generated_vessels.empty?

    # create competition
    metric = Metric.create(kills: 3, deaths: -1, assists: 1, wins: 5, dmg_out: 1e-5)
    competition = Competition.new(name: "Sensitivity Analysis for #{vessel.name}")
    competition.max_stages = 40
    competition.metric = metric
    competition.ruleset = Ruleset.find(37) # use existing ruleset
    competition.user_id = user.id
    competition.save

    # assign vessels
    VesselAssignment.create(competition: competition, vessel: vessel)
    generated_vessels.each do |v|
      VesselAssignment.create(competition: competition, vessel: v)
    end

    # return configured competition
    return competition
  end

  private

  @spread_tensor = [0.8, 0.9, 1.1, 1.2]

  @available_parameters = [
      "steerMult",
      "steerKiAdjust",
      "steerDamping",
      "DynamicDampingMin",
      "DynamicDampingMax",
      "dynamicSteerDampingFactor",
      "DynamicDampingPitchMin",
      "DynamicDampingPitchMax",
      "dynamicSteerDampingPitchFactor",
      "DynamicDampingYawMin",
      "DynamicDampingYawMax",
      "dynamicSteerDampingYawFactor",
      "DynamicDampingRollMin",
      "DynamicDampingRollMax",
      "dynamicSteerDampingRollFactor",
      "minAltitude",
      "maxSpeed",
      "takeOffSpeed",
      "minSpeed",
      "strafingSpeed",
      "idleSpeed",
      "maxSteer",
      "maxSteerAtMaxSpeed",
      "cornerSpeed",
      "maxBank",
      "maxAllowedGForce",
      "maxAllowedAoA",
      "minEvasionTime",
      "evasionThreshold",
      "evasionTimeThreshold",
      "collisionAvoidanceThreshold",
      "vesselCollisionAvoidancePeriod",
      "extendMult",
      "turnRadiusTwiddleFactorMin",
      "turnRadiusTwiddleFactorMax"
  ]
  module_function :configure
  module_function :upload_craft
end
