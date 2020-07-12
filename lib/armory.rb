module Armory
  # generate heats for a competition
  # this is idempotent; running it multiple times will produce the same result
  def generate_heats(competition, strategy=RandomDistributionStrategy.new)
    return unless competition.should_generate_heats?
    # delegate to the strategy to orchestrate the logistics
    strategy.apply!(competition)
  end

  class RandomDistributionStrategy
    def apply!(competition)
      players_per_heat = competition.players_per_heat
      groups = competition.vessels.shuffle.in_groups_of(players_per_heat, false)
      groups.each.with_index do |g,k|
        heat = competition.heats.create(stage: competition.stage, order: k)
        g.each do |v|
          HeatAssignment.create(heat_id: heat.id, vessel_id: v.id)
        end
      end
      competition.remaining_heats = competition.heats.count
      competition.save!
    end
  end
end

