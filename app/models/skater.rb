class Skater < ApplicationRecord
  belongs_to :player, optional: true
  has_many :games,  foreign_key: :skater_id,
                    class_name: "SkaterGameStatline"
  require 'open-uri'

  def self.scrape_skaters
    url = "http://www.nhl.com/stats/rest/skaters?isAggregate=false&reportType=basic&isGame=false&reportName=skatersummary&cayenneExp=gameTypeId=3%20and%20seasonId%3E=20172018%20and%20seasonId%3C=20172018"
    skaters = JSON.parse(Nokogiri::HTML(open(url)))
    skaters["data"].each do |skater|
      p = Player.new
      p.update_attributes(id: skater["playerId"].to_i,
                          skater_id: skater["playerId"].to_i,
                          first_name: skater["playerFirstName"],
                          last_name: skater["playerLastName"],
                          position: skater["playerPositionCode"],
                          number: skater["playerNumber"],
                          team: skater["playerTeamsPlayedFor"]
                        )
      p.save

      sk = Skater.new
      sk.update_attributes(id: skater["playerId"].to_i,
                          first_name: skater["playerFirstName"],
                          last_name: skater["playerLastName"],
                          position: skater["playerPositionCode"],
                          number: skater["playerNumber"],
                          team: skater["playerTeamsPlayedFor"]
                        )
      sk.save
    end
  end

  def update_statline
    r1 = self.games.where(round: 1)
    r2 = self.games.where(round: 2)
    r3 = self.games.where(round: 3)
    r4 = self.games.where(round: 4)

    r1_goals = r1.sum(:goals)
    r1_assists = r1.sum(:assists)
    r1_points = r1.sum(:points)
    r1_game_winning_goals = r1.sum(:game_winning_goals)
    r1_total = r1_points + r1_game_winning_goals

    r2_goals = r2.sum(:goals)
    r2_assists = r2.sum(:assists)
    r2_points = r2.sum(:points)
    r2_game_winning_goals = r2.sum(:game_winning_goals)
    r2_total = r2_points + r2_game_winning_goals

    r3_goals = r3.sum(:goals)
    r3_assists = r3.sum(:assists)
    r3_points = r3.sum(:points)
    r3_game_winning_goals = r3.sum(:game_winning_goals)
    r3_total = r3_points + r3_game_winning_goals

    r4_goals = r4.sum(:goals)
    r4_assists = r4.sum(:assists)
    r4_points = r4.sum(:points)
    r4_game_winning_goals = r4.sum(:game_winning_goals)
    r4_total = r4_points + r4_game_winning_goals

    if r4.count > 0
      latest_round = 4
    elsif r3.count > 0
      latest_round = 3
    elsif r2.count > 0
      latest_round = 2
    else
      latest_round = 1
    end

    self.update_attributes(r1_goals: r1_goals,
                            r1_assists: r1_assists,
                            r1_points: r1_points,
                            r1_game_winning_goals: r1_game_winning_goals,
                            r2_goals: r2_goals,
                            r2_assists: r2_assists,
                            r2_points: r2_points,
                            r2_game_winning_goals: r2_game_winning_goals,
                            r3_goals: r3_goals,
                            r3_assists: r3_assists,
                            r3_points: r3_points,
                            r3_game_winning_goals: r3_game_winning_goals,
                            r4_goals: r4_goals,
                            r4_assists: r4_assists,
                            r4_points: r4_points,
                            r4_game_winning_goals: r4_game_winning_goals,
                            r1_total: r1_total,
                            r2_total: r2_total,
                            r3_total: r3_total,
                            r4_total: r4_total
                          )

    RosterPlayer.where(player_id: self.id, round: 1).update_all(round_total: r1_total)
    RosterPlayer.where(player_id: self.id, round: 2).update_all(round_total: r2_total)
    RosterPlayer.where(player_id: self.id, round: 3).update_all(round_total: r3_total)
    RosterPlayer.where(player_id: self.id, round: 4).update_all(round_total: r4_total)
    Player.find(self.id).update_attributes(rounds: latest_round)
  end

  def self.update_all_statlines
    Skater.all.each do |skater|
      skater.update_statline
    end
  end

  def full_name
    return "#{first_name} #{last_name}"
  end

  def name_last_first
    return "#{last_name}, #{first_name}"
  end
end
