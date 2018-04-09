class RosterPlayer < ApplicationRecord
  belongs_to :general_manager
  belongs_to :player

  validates :player_id, uniqueness: { scope: [:round, :general_manager] }
  before_save :has_roster_space
  before_save :lineup_open

  private
    def has_roster_space
      player = Player.find(self.player_id)
      gm = GeneralManager.find(self.general_manager_id)
      league = League.find(self.league_id)
      round = self.round

      if player.position == "G"
        throw :abort if gm.roster_players.where(round: round, position: "G").count >= league["r#{round}_g_count".to_sym]
      elsif player.position == "D"
        throw :abort if gm.roster_players.where(round: round, position: "D").count >= league["r#{round}_d_count".to_sym]
      else
        throw :abort if gm.roster_players.where(round: round, position: "F").count >= league["r#{round}_fw_count".to_sym]
      end
    end

    def lineup_open
      throw :abort if Round.lineup_round == false || Round.lineup_round != self.round
    end
end
