class SeasonView
  def initialize(season)
    sql = <<-SQL
      SELECT t.id, g.week_id, g.id as game_id, t.name, SUM(sc.points) as Total
      FROM seasons as s
      JOIN games as g
      ON s.id = g.season_id
      JOIN game_teams as gt
      ON g.id = gt.game_id
      JOIN teams as t
      ON t.id = gt.team_id
      JOIN scores AS sc
      ON t.id = sc.team_id
      AND g.id = sc.game_id
      WHERE s.id = #{season.id}
      GROUP BY 1, 2, 3
      ORDER BY 2;
    SQL

    team_scores = ActiveRecord::Base.connection.exec_query(sql)

    @season = {
      id: season.id,
      name: season.name,
      year: season.year,
      teams: team_scores_hash(team_scores)
    }
  end

  private

  def team_scores_hash(team_scores)
    team_scores.pluck("id", "name")
               .uniq
               .map { |id, name| build_scores(team_scores, id, name) }
  end

  def build_scores(team_scores, id, name)
    filtered_teams = team_scores.select { |team| [team["id"], team["name"]] == [id, name] }
    total_arr = filtered_teams.pluck("total")

    {
      id: id,
      name: name,
      average: average_score(total_arr),
      best: best_score(total_arr),
      scores: scores(filtered_teams)
    }
  end

  def average_score(total_arr)
    total_arr.sum / total_arr.size rescue 1
  end

  def best_score(total_arr)
    total_arr.max rescue 0
  end

  def scores(teams)
    teams.map do |team|
      { game_id: team["game_id"], week_id: team["week_id"], total: team["total"] }
    end
  end

end
