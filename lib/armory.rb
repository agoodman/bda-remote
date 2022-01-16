module Armory
  # generate heats for a competition
  # this is idempotent; running it multiple times will produce the same result
  def generate_heats(competition, stage, strategy, force=false)
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
      npc_vessels = competition.vessels.includes(:player).where(players: { is_human: false }) rescue []
      player_vessels = competition.vessels.includes(:player).where(players: { is_human: true })
      players_per_heat = competition.players_per_heat(player_vessels.count)
      puts "RandomDistribution for #{player_vessels.count} players in groups of #{players_per_heat}"
      groups = player_vessels.shuffle.in_groups_of(players_per_heat, false).map { |g| g + npc_vessels }
      generate_with_groups(competition, stage, groups)
    end
  end

  class TournamentRankingStrategy < GroupedStragegy
    def apply!(competition, stage)
      ranked_vessels = competition.rankings.includes(:vessel).sort_by { |e| e.score }.map(&:vessel)
      npc_vessels = competition.vessels.includes(:player).where(players: { is_human: false })
      player_vessels = ranked_vessels.filter { |v| v.player.is_human }
      players_per_heat = competition.players_per_heat(player_vessels.count)
      groups = player_vessels.in_groups_of(players_per_heat, false).map { |g| g + npc_vessels }
      generate_with_groups(competition, stage, groups)
    end
  end

  class SinglePlayerStrategy < GroupedStragegy
    def apply!(competition, stage)
      npc_vessels = competition.vessels.includes(:player).where(players: { is_human: false })
      player_vessels = competition.vessels.includes(:player).where(players: { is_human: true })
      players_per_heat = 1
      groups = player_vessels.in_groups_of(players_per_heat, false).map { |g| g + npc_vessels }
      generate_with_groups(competition, stage, groups)
    end
  end
end

