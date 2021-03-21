# Sensitivity Analysis Module
#
# Designed to configure a spread of parametric variants from a baseline vessel.
#
module Sensitivity
  require "open-uri"

  def configure(vessel, owner)
    # fetch craft file
    craft = URI::open(vessel.craft_url).read

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
            result = "#{match[1]}#{match[2].to_f * v}"
            # puts "in: #{line}, out[#{v}]: #{result}"
            result
          end
        end
        new_craft = new_craft_lines.join("\n")
        new_name = "#{vessel.name}Mk#{index}"
        new_vessel = upload_craft(new_craft, new_name, owner)
        if new_vessel.nil?
          return nil
        end
        generated_vessels.push(new_vessel)
        index = index + 1
      end
    end

    return nil

    # create competition
    competition = Competition.new(name: "Sensitivity Analysis for #{vessel.name}")
    competition.user_id = owner.id
    competition.save

    # assign vessels
    generated_vessels.each do |v|
      VesselAssignment.create(competition: competition, vessel: v)
    end

    # return configured competition
    return competition
  end

  def upload_craft(craft, name, owner)
    s3 = Aws::S3::Resource.new(region: ENV['AWS_REGION'])
    bucket = s3.bucket(ENV['S3_BUCKET'])
    return nil if bucket.nil?

    filename = "players/#{owner.id}/#{name}"
    s3obj = bucket.object(filename)
    s3obj.put(
        body: craft,
        acl: "public-read"
    )

    craft_url = s3obj.public_url
    vessel = Vessel.create(player_id: owner.id, craft_url: craft_url, name: name)
    vessel
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
