class Player < ApplicationRecord
  has_many :roster_players
  has_many :general_managers, :through => :roster_players

  scope :forwards, -> { where(position: ["C", "LW", "RW", "L", "R"]) }
  scope :defensemen, -> { where(position: "D") }
  scope :goalies, -> { where(position: "G") }

  validates :id, uniqueness: true

  require 'open-uri'

  def full_name
    return "#{first_name} #{last_name}"
  end

  def name_last_first
    return "#{last_name}, #{first_name}"
  end

  def statline
    if position == "G"
      Goalie.find(self.skater_id)
    else
      Skater.find(self.skater_id)
    end
  end

  def position_category
    unless position == "G" || position == "D"
      return "F"
    end

    return position
  end

  def self.seed
    url = "https://statsapi.web.nhl.com/api/v1/teams?site=en_nhl&teamId=12,52,19,21,29,6,20,25,18,2,5,28,14,10,54,15&expand=team.roster,team.stats,roster.person,person.stats&stats=statsSingleSeason"
    doc = JSON.parse(Nokogiri::HTML(open(url)))
    doc["teams"].each do |t|
      team = t["abbreviation"]
      t["roster"]["roster"].each do |player|
        p = Player.new
        p.update_attributes(id: player["person"]["id"].to_i,
                            skater_id: player["person"]["id"].to_i,
                            first_name: player["person"]["firstName"],
                            last_name: player["person"]["lastName"],
                            position: player["position"]["code"],
                            number: player["person"]["primaryNumber"],
                            team: team
                          )

        if player["position"]["code"] == "G"
          g = Goalie.new
          g.update_attributes(id: player["person"]["id"].to_i,
                              first_name: player["person"]["firstName"],
                              last_name: player["person"]["lastName"],
                              position: player["position"]["code"],
                              number: player["person"]["primaryNumber"],
                              team: team
                            )
        else
          sk = Skater.new
          sk.update_attributes(id: player["person"]["id"].to_i,
                              first_name: player["person"]["firstName"],
                              last_name: player["person"]["lastName"],
                              position: player["position"]["code"],
                              number: player["person"]["primaryNumber"],
                              team: team
                            )
        end
      end
    end
  end

end
