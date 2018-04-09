class RosterPlayersController < ApplicationController
  protect_from_forgery
  before_action :authenticate_user!

  def create
    gm = GeneralManager.find(params[:general_manager_id])
    round = params[:round_number]
    player = Player.find(params[:roster_player][:player_id])
    gm.roster_players.build(player_id: player.id, position: player.position_category, general_manager_id: gm.id, league_id: gm.league_id, round: round)
    gm.save if !current_user.teams.find_by(id: gm.id).nil?

    redirect_to user_general_manager_path(gm.user_id, gm, round_number: round)
  end

  def destroy
    p = RosterPlayer.find(params[:id])
    round = p.round
    gm = GeneralManager.find(p.general_manager_id)
    p.destroy if !current_user.teams.find_by(id: gm.id).nil?

    redirect_to user_general_manager_path(gm.user_id, gm, round_number: round)
  end
end
