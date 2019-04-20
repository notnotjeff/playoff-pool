# frozen_string_literal: true

class GeneralManagersController < ApplicationController
  before_action :is_owner, only: :create
  before_action :is_user, only: :destroy

  def create
    @gm = GeneralManager.new(general_manager_params)
    @gm.league_id = params[:league_id].to_i
    if @gm.save
      flash[:success] = 'Team added!'
      @gm.update_attributes(name: @gm.user.name)
    end
    redirect_to league_path(League.find(@gm.league_id))
  end

  def destroy
    @gm = GeneralManager.find(params[:id])
    league = @gm.league
    flash[:success] = 'Team deleted!'
    @gm.destroy
    redirect_to league_path(league)
  end

  def show
    @gm = GeneralManager.find(params[:id].to_i)
    @league = @gm.league

    @forwards = @gm.roster_players.where(position: 'F')
                   .joins("LEFT JOIN skater_game_statlines sgs ON sgs.skater_id = roster_players.player_id AND sgs.game_date = '#{(Time.now - 12.hours).strftime('%Y-%m-%d')}'")
                   .joins('LEFT JOIN skaters ON skaters.id = roster_players.player_id')
                   .select('roster_players.*, CASE WHEN sgs.id > 0 THEN true ELSE false END AS playing, sgs.round AS round, skaters.*')
                   .order(round_total: :desc)
    @defensemen = @gm.roster_players.where(position: 'D')
                     .joins("LEFT JOIN skater_game_statlines sgs ON sgs.skater_id = roster_players.player_id AND sgs.game_date = '#{(Time.now - 12.hours).strftime('%Y-%m-%d')}'")
                     .joins('LEFT JOIN skaters ON skaters.id = roster_players.player_id')
                     .select('roster_players.*, CASE WHEN sgs.id > 0 THEN true ELSE false END AS playing, sgs.round AS round, skaters.*')
                     .order(round_total: :desc)
    @goalies = @gm.roster_players
                  .where(position: 'G')
                  .joins("LEFT JOIN goalie_game_statlines ggs ON ggs.skater_id = roster_players.player_id AND ggs.game_date = '#{(Time.now - 12.hours).strftime('%Y-%m-%d')}'")
                  .joins('LEFT JOIN goalies ON goalies.id = roster_players.player_id')
                  .select('roster_players.*, CASE WHEN ggs.id > 0 THEN true ELSE false END AS playing, ggs.round AS round, goalies.*')
                  .order(round_total: :desc)

    @r1 = @r2 = @r3 = @r4 = ''
    @round = params[:round_number].nil? ? Round.current_round : params[:round_number].to_i
    @lineup_round = Round.lineup_round

    if @round == 4
      @r4 = "active"
    elsif @round == 2
      @r2 = "active"
    elsif @round == 3
      @r3 = "active"
    else
      @r1 = "active"
    end
  end

  def edit
    @gm = GeneralManager.find(params[:id])
  end

  def update
    @gm = GeneralManager.find(params[:id])
    @gm.update_attributes(general_manager_params)
    if @gm.save
      flash[:success] = "Team updated!"
      redirect_to user_general_manager_path(@gm)
    else
      render 'edit'
    end
  end

  private

  def general_manager_params
    params.require(:general_manager).permit(:user_id, :name, :league_id)
  end

  def is_owner
    @league = current_user.leagues.find(params[:league_id].to_i)
    redirect_to root_url if @league.nil?
  end

  def is_user
    @gm = GeneralManager.find(params[:id])
    redirect_to root_url if current_user == @gm.user
  end
end
