class SkaterGameStatline < ApplicationRecord
  belongs_to :skater, optional: true
  validates :skater_id, uniqueness: { scope: [:game_id, :game_date] }

  require 'open-uri'

  def self.scrape_all_games
    rounds = Round.get_rounds_hash

    games_url = "http://www.nhl.com/stats/rest/skaters?isAggregate=false&reportType=basic&isGame=true&reportName=skatersummary&cayenneExp=gameDate%3E=%222018-04-09%22%20and%20gameDate%3C=%222018-07-03%22%20and%20gameTypeId=3"
    games = JSON.parse(Nokogiri::HTML(open(games_url)))
    games["data"].each do |game|
      round_number = rounds[game["teamAbbrev"].to_sym][game["opponentTeamAbbrev"].to_sym].to_i
      SkaterGameStatline.scrape_game(game, round_number)
    end

    Skater.all.each do |skater|
      skater.update_statline
    end
  end

  def self.scrape_todays_games(date, rounds)

    games_url = "http://www.nhl.com/stats/rest/skaters?isAggregate=false&reportType=basic&isGame=true&reportName=skatersummary&cayenneExp=gameDate%3E=%22#{date}%22%20and%20gameDate%3C=%22#{date}%2023:59:59%22%20and%20gameTypeId=3"
    games = JSON.parse(Nokogiri::HTML(open(games_url)))
    games["data"].each do |game|
      round_number = rounds[game["teamAbbrev"].to_sym][game["opponentTeamAbbrev"].to_sym].to_i
      sgs = SkaterGameStatline.find_by(game_id: game["gameId"].to_i, skater_id: game["playerId"].to_i)
      if sgs.nil?
        SkaterGameStatline.scrape_game(game, round_number)
      else
        sgs.update_attributes(goals: game["goals"],
                              assists: game["assists"],
                              points: game["points"],
                              game_winning_goals: game["gameWinningGoals"],
                              ot_goals: game["otGoals"]
                            )
        sgs.skater.update_statline
        sgs.save
      end
    end
  end

  def self.update_todays_games
  end

  def self.scrape_game(game, round_number)
    sgs = SkaterGameStatline.new
    Skater.find_or_create_by(id: game["playerId"].to_i,
                              first_name: game["playerFirstName"],
                              last_name: game["playerLastName"],
                              position: game["playerPositionCode"],
                              team: game["teamAbbrev"])
    Player.find_or_create_by(id: game["playerId"].to_i,
                              skater_id: game["playerId"].to_i,
                              first_name: game["playerFirstName"],
                              last_name: game["playerLastName"],
                              position: game["playerPositionCode"],
                              team: game["teamAbbrev"],
                              rounds: round_number)

    sgs.update_attributes(skater_id: game["playerId"].to_i,
                          position: game["playerPositionCode"],
                          team: game["teamAbbrev"],
                          opposition: game["opponentTeamAbbrev"],
                          game_date: game["gameDate"].to_date,
                          game_id: game["gameId"].to_i,
                          goals: game["goals"],
                          assists: game["assists"],
                          points: game["points"],
                          game_winning_goals: game["gameWinningGoals"],
                          ot_goals: game["otGoals"],
                          round: round_number
                        )
    sgs.skater.update_statline
    sgs.save
  end

  def self.scrape_round(r)
    rounds = Round.get_rounds_hash
    round = Round.find_by(round_number: r)

    return "Round needs a start and end date" if round.start_date.nil || round.end_date.nil?
    s_date = round.start_date.strftime("%Y-%m-%d")
    e_date = round.end_date.strftime("%Y-%m-%d")

    games_url = "http://www.nhl.com/stats/rest/skaters?isAggregate=false&reportType=basic&isGame=true&reportName=skatersummary&cayenneExp=gameDate%3E=%22#{s_date}%22%20and%20gameDate%3C=%22#{e_date}%22%20and%20gameTypeId=3"
    games = JSON.parse(Nokogiri::HTML(open(games_url)))
    games["data"].each do |game|
      round_number = rounds[game["teamAbbrev"].to_sym][game["opponentTeamAbbrev"].to_sym].to_i
      SkaterGameStatline.scrape_game(game, round_number)
    end

    Skater.all.each do |skater|
      skater.update_statline
    end
  end
end
