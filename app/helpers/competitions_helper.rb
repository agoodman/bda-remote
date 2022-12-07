module CompetitionsHelper

  def vessel_file_name_for_player(competition, player)
    competition.vessels.where(player_id: player.id).first.craft_url.split("/").last
  end

  def as_meta(competition)
    {
        title: "Competition #{competition.name}",
        description: (competition.ruleset.summary rescue ""),
        url: competition_path(competition)
    }
  end

end
