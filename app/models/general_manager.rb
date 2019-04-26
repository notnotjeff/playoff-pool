class GeneralManager < ApplicationRecord
  belongs_to :league
  belongs_to :user
  has_many :roster_players
  has_many :players, through: :roster_players

  validates :league_id, uniqueness: { scope: [:user_id], message: 'User is already in this league' }
  validates :name, length: { maximum: 25 }
  before_create :not_started?

  def player_pool
    remaining_teams = Round.get_rounds_hash
                           .select { |_t, o| o.length >= Round.lineup_round }
                           .map { |t| t[0].to_s }
    player_ids = RosterPlayer.where(general_manager_id: id).pluck(:player_id)

    Player.where(team: remaining_teams)
          .where.not(id: player_ids)
          .order(last_name: :asc)
  end

  def rank
    league.teams.order(points: :desc)
  end

  def update_statline(round)
    skater_points = roster_players.where(round: round)
                                  .joins('INNER JOIN skaters ON skaters.id = roster_players.player_id')
                                  .sum("r#{round}_total".to_sym).to_i
    goalie_points = roster_players.where(round: round)
                                  .joins('INNER JOIN goalies ON goalies.id = roster_players.player_id')
                                  .sum("r#{round}_total".to_sym).to_i

    total = skater_points + goalie_points
    self["r#{round}_points".to_sym] = total
    update(points: r1_points.to_i + r2_points.to_i + r3_points.to_i + r4_points.to_i)
  end

  def self.update_all_rounds
    GeneralManager.all.each do |gm|
      round = Round.current_round
      while round.positive?
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

  def not_started?
    throw :abort if Round.current_round.positive? # If playoffs have started don't let new teams in
  end
end
