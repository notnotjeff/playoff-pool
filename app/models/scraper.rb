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
      home_team = game_doc["liveData"]["boxscore"]["teams"]["home"]["team"]["abbreviation"]
      away_team = game_doc["liveData"]["boxscore"]["teams"]["away"]["team"]["abbreviation"]
      round = round_hash[home_team.to_sym][away_team.to_sym]

      if status != 'Final'
        Scraper.update_team(game_doc["liveData"]["boxscore"]["teams"]["away"]["players"], game_doc["gameData"]["players"], away_team, home_team, round, date, game)
        Scraper.update_team(game_doc["liveData"]["boxscore"]["teams"]["home"]["players"], game_doc["gameData"]["players"], home_team, away_team, round, date, game)
      end
    end

    SkaterGameStatline.scrape_todays_games(date, round_hash)
    GoalieGameStatline.scrape_todays_games(date, round_hash)
    GeneralManager.update_round(Round.current_round)
  end

  def self.update_team(players, game_rosters, team, opposition, round, date, game)
    players.each do |player|
      player_id = player[1]["person"]["id"].to_i
      profile = Player.find_or_create_by(id: player_id, skater_id: player_id, team: team, first_name: game_rosters["ID#{player_id}"]["firstName"], last_name: game_rosters["ID#{player_id}"]["lastName"], position: game_rosters["ID#{player_id}"]["primaryPosition"]["code"], rounds: round)
      Skater.find_or_create_by(id: player_id, team: team, first_name: game_rosters["ID#{player_id}"]["firstName"], last_name: game_rosters["ID#{player_id}"]["lastName"], position: game_rosters["ID#{player_id}"]["primaryPosition"]["code"])
      next if player[1]["stats"] == {}

      if profile.position != "G"
        SkaterGameStatline.where(game_id: game, skater_id: player_id).first_or_create(game_date: date.to_date, team: team, opposition: opposition, position: profile.position, round: round)
        sgs = SkaterGameStatline.find_by(game_id: game, skater_id: player_id)
        goals = player[1]["stats"]["skaterStats"]["goals"].to_i
        assists = player[1]["stats"]["skaterStats"]["assists"].to_i
        points = goals + assists

        sgs.update_attributes(goals: goals, assists: assists, points: points)
        sgs.skater.update_statline
      end
    end
  end

  def self.scrape_range_of_dates(start_date, end_date)
    rounds = Round.get_rounds_hash
    dates = []

    (start_date..end_date).each do |date|
      dates << date.strftime("%Y-%m-%d")
    end

    dates.each do |date|
      SkaterGameStatline.scrape_todays_games(date, rounds)
      GoalieGameStatline.scrape_todays_games(date, rounds)
    end

    Skater.update_all_statlines
    GeneralManager.update_round(Round.current_round)
  end

  def self.games_today?
    date = Time.now.to_date.strftime("%Y-%m-%d")
    url = "https://statsapi.web.nhl.com/api/v1/schedule?startDate=#{date}&endDate=#{date}"
    doc = JSON.parse(Nokogiri::HTML(open(url)))

    return true if doc["dates"].count.positive?

    false
  end
end
