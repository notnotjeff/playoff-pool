# frozen_string_literal: true

class RosterPlayersController < ApplicationController
  protect_from_forgery
  before_action :authenticate_user!
  before_action :owner?
  before_action :played_in_round?, only: %i[create]

  def create
    gm = GeneralManager.find(params[:general_manager_id])
    round = params[:round_number]
    player = Player.find(params[:roster_player][:player_id])
    gm.roster_players.build(player_id: player.id, position: player.position_category, general_manager_id: gm.id, league_id: gm.league_id, round: round)
    gm.save if current_user.teams.find_by(id: gm.id) || current_user == gm.league.user

    redirect_to user_general_manager_path(gm.user_id, gm, round_number: round)
  end

  def destroy
    p = RosterPlayer.find(params[:id])
    round = p.round
    gm = GeneralManager.find(p.general_manager_id)
    p.destroy if current_user.teams.find_by(id: gm.id) || current_user == gm.league.user

    redirect_to user_general_manager_path(gm.user_id, gm, round_number: round)
  end

  def import
    round = params[:round_number]
    gm = GeneralManager.find(params[:general_manager_id])
    if current_user.teams.find_by(id: gm.id)
      errors = RosterPlayer.import(params[:file], round, gm)
      flash[:success] = 'Roster imported!'
      errors.each do |error|
        flash[:danger] ||= ""
        flash[:danger] += "#{error} <br>"
      end
    end

    redirect_to user_general_manager_path(gm.user_id, gm, round_number: round)
  end

  private

  def owner?
    return if current_user == League.find(params[:league_id]).user

    return if current_user == GeneralManager.find(params[:general_manager_id]).user

    redirect_to root_path
  end

  def played_in_round?
    return if current_user == League.find(params[:league_id]).user # Admin can add players even after they have started playing

    player = Player.find(params[:roster_player][:player_id])
    redirect_to root_path if player.nil?

    redirect_to root_path if player.position == 'G' && GoalieGameStatline.where('round <= ?', Round.current_round).any?
    redirect_to root_path if player.position != 'G' && SkaterGameStatline.where('round <= ?', Round.current_round).any?
  end
end
