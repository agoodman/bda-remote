module Armory
  # generate heats for a competition
  # this is idempotent; running it multiple times will produce the same result
  def generate_heats(competition, stage, force=false, strategy=RandomDistributionStrategy.new)
    return unless force || competition.should_generate_heats?
    # delegate to the strategy to orchestrate the logistics
    strategy.apply!(competition, stage)
  end

  class GroupedStragegy
    def generate_with_groups(competition, stage, groups)
      groups.each.with_index do |g,k|
        heat = competition.heats.where(stage: stage, order: k).first_or_create
        g.each do |v|
          HeatAssignment.where(heat_id: heat.id, vessel_id: v.id).first_or_create
        end
      end
    end
  end

  class RandomDistributionStrategy < GroupedStragegy
    def apply!(competition, stage)
      players_per_heat = competition.players_per_heat
      puts "RandomDistribution for #{competition.vessels.count} players in groups of #{players_per_heat}"
      groups = competition.vessels.shuffle.in_groups_of(players_per_heat, false)
      generate_with_groups(competition, stage, groups)
    end
  end

  class TournamentRankingStrategy < GroupedStragegy
    def apply!(competition, stage)
      players_per_heat = competition.players_per_heat
      ranked_vessels = competition.rankings.includes(:vessel).sort_by { |e| e.score }.map(&:vessel)
      groups = ranked_vessels.in_groups_of(players_per_heat, false)
      generate_with_groups(competition, stage, groups)
    end
  end

end

