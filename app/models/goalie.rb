class Goalie < ApplicationRecord
  belongs_to :player, optional: true
  has_many :games,  foreign_key: :skater_id,
                    class_name: "GoalieGameStatline"
  require 'open-uri'
  validates :id, uniqueness: true

  def self.scrape_goalies
    url = "http://www.nhl.com/stats/rest/goalies?isAggregate=false&reportType=goalie_basic&isGame=false&reportName=goaliesummary&cayenneExp=gameTypeId=3%20and%20seasonId%3E=20162017%20and%20seasonId%3C=20162017"
    goalie = JSON.parse(Nokogiri::HTML(open(url)))
    goalie["data"].each do |goalie|
      p = Player.new
      p.update_attributes(id: goalie["playerId"].to_i,
                          skater_id: goalie["playerId"].to_i,
                          first_name: goalie["playerFirstName"],
                          last_name: goalie["playerLastName"],
                          position: goalie["playerPositionCode"],
                          number: goalie["playerNumber"],
                          team: goalie["playerTeamsPlayedFor"]
                        )
      p.save

      sk = Goalie.new
      sk.update_attributes(id: goalie["playerId"].to_i,
                          first_name: goalie["playerFirstName"],
                          last_name: goalie["playerLastName"],
                          position: goalie["playerPositionCode"],
                          number: goalie["playerNumber"],
                          team: goalie["playerTeamsPlayedFor"],
                          wins: goalie["wins"],
                          shutouts: goalie["shutouts"]
                        )
      sk.save
    end
  end

  def update_statline
    r1 = self.games.where(round: 1)
    r2 = self.games.where(round: 2)
    r3 = self.games.where(round: 3)
    r4 = self.games.where(round: 4)

    r1_wins = r1.sum(:win)
    r1_shutouts = r1.sum(:shutout)
    r1_total = r1_wins + r1_shutouts

    r2_wins = r2.sum(:win)
    r2_shutouts = r2.sum(:shutout)
    r2_total = r2_wins + r2_shutouts

    r3_wins = r3.sum(:win)
    r3_shutouts = r3.sum(:shutout)
    r3_total = r3_wins + r3_shutouts

    r4_wins = r4.sum(:win)
    r4_shutouts = r4.sum(:shutout)
    r4_total = r4_wins + r4_shutouts

    if r4.count > 0
      latest_round = 4
    elsif r3.count > 0
      latest_round = 3
    elsif r2.count > 0
      latest_round = 2
    else
      latest_round = 1
    end

    self.update_attributes(r1_wins: r1_wins,
                            r1_shutouts: r1_shutouts,
                            r2_wins: r2_wins,
                            r2_shutouts: r2_shutouts,
                            r3_wins: r3_wins,
                            r3_shutouts: r3_shutouts,
                            r4_wins: r4_wins,
                            r4_shutouts: r4_shutouts,
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
    Goalie.all.each do |go|
      go.update_statline
    end
  end

  def full_name
    return "#{first_name} #{last_name}"
  end

  def name_last_first
    return "#{last_name}, #{first_name}"
  end
end
