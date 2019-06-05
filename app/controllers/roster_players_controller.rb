# frozen_string_literal: true

class RosterPlayersController < ApplicationController
  protect_from_forgery
  before_action :authenticate_user!
  before_action :owner?
  before_action :played_in_round?, only: %i[create destroy]
  before_action :roster_space?, only: %i[create]

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

  def is_open_round?
    return if current_user == League.find(params[:league_id]).user # Admin can manage players even if it isn't the current round

    redirect_to root_path if params[:round_number].to_i >= Round.current_round && params[:round_number].to_i <= Round.current_round + 1 || params[:round_number].to_i > 4
  end

  def played_in_round?
    return if current_user == League.find(params[:league_id]).user # Admin can add players even after they have started playing

    player = Player.find(params[:roster_player][:player_id])
    redirect_to root_path if player.nil?

    starting_times = Rails.cache.fetch('series_start_times_hash') { Round.scrape_series_start_times }
    redirect_to root_path if starting_times[player.team.to_sym][params[:round_number].to_i][:start_time] == true
  end

  def roster_space?
    player = Player.find(params[:roster_player][:player_id])
    gm = GeneralManager.find(params[:general_manager_id])
    league = League.find(params[:league_id])
    round = params[:round_number].to_i

    if player.position == 'G'
      redirect_to root_path if gm.roster_players.where(round: round, position: 'G').count >= league["r#{round}_g_count".to_sym]
    elsif player.position == 'D'
      redirect_to root_path if gm.roster_players.where(round: round, position: 'D').count >= league["r#{round}_d_count".to_sym]
    else
      redirect_to root_path if gm.roster_players.where(round: round, position: 'F').count >= league["r#{round}_fw_count".to_sym]
    end
  end
end
