class Scraper < ApplicationRecord
  require 'open-uri'
  
  def self.update_day_of_games(date) #YYYY-MM-DD
    schedule_url = "https://statsapi.web.nhl.com/api/v1/schedule?startDate=#{date}&endDate=#{date}"
    sched_doc = JSON.parse(Nokogiri::HTML(open(schedule_url)))
    game_ids = []
    round_hash = Round.get_rounds_hash

    sched_doc["dates"][0]["games"].each do |game|
      game_ids << game["gamePk"].to_s
    end

    game_ids.each do |game|
      game_url = "https://statsapi.web.nhl.com/api/v1/game/#{game}/feed/live"
      game_doc = JSON.parse(Nokogiri::HTML(open(game_url)))
      status = game_doc["gameData"]["status"]["abstractGameState"]
      home_team = game_doc["liveData"]["boxscore"]["teams"]["away"]["team"]["abbreviation"]
      away_team = game_doc["liveData"]["boxscore"]["teams"]["home"]["team"]["abbreviation"]
      round = round_hash[home_team.to_sym][away_team.to_sym]

      if status != "Final"
        Scraper.update_team(game_doc["liveData"]["boxscore"]["teams"]["away"]["players"], away_team, home_team, round, date, game)
        Scraper.update_team(game_doc["liveData"]["boxscore"]["teams"]["home"]["players"], home_team, away_team, round, date, game)
      end
    end

    SkaterGameStatline.scrape_todays_games(date, round_hash)
    GoalieGameStatline.scrape_todays_games(date, round_hash)
  end

  def self.update_team(players, team, opposition, round, date, game)
    players.each do |player|
      profile = Player.find_by(skater_id: player[1]["person"]["id"].to_i)
      next if player[1]["stats"] == {}

      if profile.position != "G"
        SkaterGameStatline.where(game_id: game, skater_id: player[1]["person"]["id"].to_i).first_or_create(game_date: date.to_date, team: team, opposition: opposition, position: profile.position, round: round)
        sgs = SkaterGameStatline.find_by(game_id: game, skater_id: player[1]["person"]["id"])
        goals = player[1]["stats"]["skaterStats"]["goals"].to_i
        assists = player[1]["stats"]["skaterStats"]["assists"].to_i
        points = goals + assists

        sgs.update_attributes(goals: goals, assists: assists, points: points)
      end
    end
  end
end
