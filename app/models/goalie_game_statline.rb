class GoalieGameStatline < ApplicationRecord
  belongs_to :goalie, optional: true,
                      foreign_key: :skater_id
  validates :skater_id, uniqueness: { scope: [:game_id, :game_date] }
  require 'open-uri'

  def self.scrape_all_games
    rounds = Round.get_rounds_hash

    games_url = "http://www.nhl.com/stats/rest/goalies?isAggregate=false&reportType=goalie_basic&isGame=true&reportName=goaliesummary&cayenneExp=gameDate%3E=%222018-04-09%22%20and%20gameDate%3C=%222018-07-01%22%20and%20gameTypeId=3"
    games = JSON.parse(Nokogiri::HTML(open(games_url)))
    games["data"].each do |game|
      round_number = rounds[game["teamAbbrev"].to_sym][game["opponentTeamAbbrev"].to_sym].to_i
      GoalieGameStatline.scrape_game(game, round_number)
    end

    Goalie.all.each do |skater|
      skater.update_statline
    end
  end

  def self.scrape_todays_games(date, rounds)
    time = Time.now

    games_url = "http://www.nhl.com/stats/rest/goalies?isAggregate=false&reportType=basic&isGame=true&reportName=goaliesummary&cayenneExp=gameDate%3E=%22#{date}%22%20and%20gameDate%3C=%22#{date}%2023:59:59%22%20and%20gameTypeId=3"
    games = JSON.parse(Nokogiri::HTML(open(games_url)))
    games["data"].each do |game|
      round_number = rounds[game["teamAbbrev"].to_sym][game["opponentTeamAbbrev"].to_sym].to_i
      ggs = GoalieGameStatline.find_by(game_id: game["gameId"].to_i, skater_id: game["playerId"].to_i)

      if ggs.nil?
        GoalieGameStatline.scrape_game(game, round_number)
      else
        ggs.update_attributes(win: game["wins"],
                              shutout: game["shutouts"]
                            )
        ggs.goalie.update_statline
        ggs.save
      end
    end
  end

  def self.update_todays_games
  end

  def self.scrape_game(game, round_number)
    ggs = GoalieGameStatline.new

    ggs.update_attributes(skater_id: game["playerId"].to_i,
                          position: game["playerPositionCode"],
                          team: game["teamAbbrev"],
                          opposition: game["opponentTeamAbbrev"],
                          game_date: game["gameDate"].to_date,
                          game_id: game["gameId"].to_i,
                          win: game["wins"],
                          shutout: game["shutouts"],
                          round: round_number
                        )
    ggs.goalie.update_statline
    ggs.save
  end

  def self.scrape_round(r)
    rounds = Round.get_rounds_hash
    round = Round.find_by(round_number: r)

    return "Round does not have a start and end date" if round.start_date.nil? || round.end_date.nil?

    games_url = "http://www.nhl.com/stats/rest/skaters?isAggregate=false&reportType=basic&isGame=true&reportName=skatersummary&cayenneExp=gameDate%3E=%22#{round.start_date.strftime("%Y-%m-%d")}%22%20and%20gameDate%3C=%22#{round.end_date.strftime("%Y-%m-%d")}%22%20and%20gameTypeId=3"
    games = JSON.parse(Nokogiri::HTML(open(games_url)))
    games["data"].each do |game|
      round_number = rounds[game["teamAbbrev"].to_sym][game["opponentTeamAbbrev"].to_sym].to_i
      GoalieGameStatline.scrape_game(game, round_number)
    end

    Goalie.all.each do |skater|
      skater.update_statline
    end
  end
end
