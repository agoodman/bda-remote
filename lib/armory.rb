module Armory
  # generate heats for a competition
  # this is idempotent; running it multiple times will produce the same result
  def generate_heats(competition, stage, strategy, force=false)
    return unless force || competition.should_generate_heats?
    # delegate to the strategy to orchestrate the logistics
    strategy.apply!(competition, stage)
  end

  class GroupedStrategy
    def generate_with_groups(competition, stage, groups)
      groups.each.with_index do |g,k|
        heat = competition.heats.where(stage: stage, order: k).first_or_create
        g.each do |v|
          HeatAssignment.where(heat_id: heat.id, vessel_id: v.id).first_or_create
        end
      end
    end

    # Pass shuffled vessels for randomised, or ordered for ranked
    def generate_groups(competition, limits, player_vessels)
      vessel_count = player_vessels.length
      players_per_full_heat, heats_with_one_less = competition.players_per_heat_v2(vessel_count, limits)
      full_heats = (vessel_count / players_per_full_heat.to_f - heats_with_one_less).ceil
      groups = full_heats > 0 ?
        Array(0..full_heats - 1).map {|s| player_vessels.slice(s * players_per_full_heat, players_per_full_heat)}.concat(
          Array(0..heats_with_one_less - 1).map {|s| player_vessels.slice(full_heats * players_per_full_heat + s * (players_per_full_heat - 1), players_per_full_heat - 1)}) :
        player_vessels
      return groups
    end
  end

  class RandomDistributionStrategy < GroupedStrategy
    def apply!(competition, stage)
      npc_vessels = competition.vessels.includes(:player).where(players: { is_human: false }) rescue []
      player_vessels = competition.vessels.includes(:player).where(players: { is_human: true })
      limits = competition.get_per_heat_limits()
      puts "RandomDistribution for #{player_vessels.count} players in groups of #{limits[0]}—#{limits[1]} with #{npc_vessels.length} npcs"
      groups = generate_groups(competition, limits, player_vessels.shuffle)
      groups = groups.map { |g| g + npc_vessels }
      generate_with_groups(competition, stage, groups)
    end
  end

  class TournamentRankingStrategy < GroupedStrategy
    def apply!(competition, stage)
      ranked_vessels = competition.rankings.includes(:vessel).sort_by { |e| e.score }.map(&:vessel)
      npc_vessels = competition.vessels.includes(:player).where(players: { is_human: false })
      player_vessels = ranked_vessels.filter { |v| v.player.is_human }
      limits = competition.get_per_heat_limits()
      groups = generate_groups(competition, limits, ranked_vessels)
      groups = groups.map { |g| g + npc_vessels }
      generate_with_groups(competition, stage, groups)
    end
  end

  class SinglePlayerStrategy < GroupedStrategy
    def apply!(competition, stage)
      npc_vessels = competition.vessels.includes(:player).where(players: { is_human: false })
      player_vessels = competition.vessels.includes(:player).where(players: { is_human: true })
      players_per_heat = 1
      groups = player_vessels.in_groups_of(players_per_heat, false).map { |g| g + npc_vessels }
      generate_with_groups(competition, stage, groups)
    end
  end
end

