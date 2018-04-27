class GeneralManager < ApplicationRecord
  belongs_to :league
  belongs_to :user
  has_many :roster_players
  has_many :players, :through => :roster_players

  validates :league_id, uniqueness: { scope: [:user_id], message: 'User is already in this league' }
  validates :name, length: { maximum: 25 }
  before_create :has_not_started

  def player_pool
    player_ids = RosterPlayer.where(general_manager_id: self.id).pluck(:player_id)
    if player_ids.count == 0
      return Player.where('rounds >= ?', Round.lineup_round).order(last_name: :asc)
    else
      return Player.where('rounds >= ?', Round.lineup_round).where('id NOT IN (?)', player_ids).order(last_name: :asc)
    end
  end

  def rank
    league = self.league.teams.order(points: :desc)
  end

  def update_statline(round)
    skater_points = self.roster_players.where(round: round).joins("INNER JOIN skaters ON skaters.id = roster_players.player_id").sum("r#{round}_total".to_sym).to_i
    goalie_points = self.roster_players.where(round: round).joins("INNER JOIN goalies ON goalies.id = roster_players.player_id").sum("r#{round}_total".to_sym).to_i
    total = skater_points + goalie_points

    self["r#{round}_points".to_sym] = total
    self.points = self.r1_points.to_i + self.r2_points.to_i + self.r3_points.to_i + self.r4_points.to_i
    self.save
  end

  def self.update_all_rounds
    GeneralManager.all.each do |gm|
      round = Round.current_round
      while round > 0
        gm.update_statline(round)
        round -= 1
      end
    end
  end

  def self.update_round(round)
    GeneralManager.all.each do |gm|
      gm.update_statline(round)
    end
  end

  private
    def has_not_started
      throw :abort if Round.current_round > 0 # If playoffs have started don't let new teams in
    end
end
