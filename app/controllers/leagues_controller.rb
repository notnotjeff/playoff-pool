class LeaguesController < ApplicationController
  protect_from_forgery

  before_action :user_signed_in?, only: %i[new create destroy]
  before_action :correct_user, only: :destroy

  def index
    @leagues = League.all.order(name: :asc)
  end

  def show
    @league = League.find(params[:id])
    @gms = GeneralManager.where(league_id: @league).order(points: :desc)
    @gm = @league.general_managers.build
    @updated_at = @league.scraped_at.nil? ? nil : @league.scraped_at.in_time_zone('Eastern Time (US & Canada)').strftime("%I:%M:%S %p %b #{@league.scraped_at.day.ordinalize}")
  end

  def new
    @league = current_user.leagues.build
  end

  def create
    @league = current_user.leagues.build(league_params)
    if @league.save
      flash[:success] = 'League created!'
      current_user.teams.build(name: current_user.name, league_id: @league)
      redirect_to @league
    else
      render 'league/create'
    end
  end

  def destroy
    @league.destroy
    flash[:success] = 'League deleted'
    redirect_to root_url
  end

  def skaters
    @round = set_round(params[:round].to_s)
    @position, @def_position = set_position(params[:position].to_s)
    @league = League.find(params[:id].to_i)

    if @round.to_i.between?(1,4)
      @skaters = RosterPlayer.where(league_id: @league, round: @round, position: @position)
                              .select("DISTINCT ON (roster_players.player_id, roster_players.round_total) * ")
                              .group("roster_players.player_id, roster_players.id, roster_players.round_total")
                              .order("roster_players.round_total desc")
    else
      @skaters = RosterPlayer.where(league_id: @league, position: @position)
                              .select("DISTINCT ON (roster_players.player_id, roster_players.round_total, roster_players.round) * ")
                              .group("roster_players.player_id, roster_players.id, roster_players.round_total, roster_players.round")
                              .order("roster_players.round_total desc")
    end
  end

  def goalies
    @round = set_round(params[:round].to_s)
    @league = League.find(params[:id].to_i)

    if @round.to_i.between?(1,4)
      @goalies = RosterPlayer.where(league_id: @league, round: @round, position: "G")
                              .select("DISTINCT ON (roster_players.player_id, roster_players.round_total) * ")
                              .group("roster_players.player_id, roster_players.id, roster_players.round_total")
                              .order("roster_players.round_total desc")
    else
      @goalies = RosterPlayer.where(league_id: @league, position: "G")
                              .select("DISTINCT ON (roster_players.player_id, roster_players.round_total, roster_players.round) * ")
                              .group("roster_players.player_id, roster_players.id, roster_players.round_total, roster_players.round")
                              .order("roster_players.round_total desc")
    end
  end

  def rules
    @league = League.find(params[:id].to_i)
  end

  private

  def league_params
    params.require(:league).permit(:name, :r1_fw_count, :r1_d_count, :r1_g_count, :r2_fw_count, :r2_d_count, :r2_g_count, :r3_fw_count, :r3_d_count, :r3_g_count, :r4_fw_count, :r4_d_count, :r4_g_count)
  end

  def correct_user
    @league = current_user.leagues.find_by(id: params[:id])
    redirect_to root_url if @league.nil?
  end

  def set_round(round)
    return Round.current_round.to_i if round == ''

    round.to_i.between?(0, 4) ? round : Round.current_round
  end

  def set_position(position)
    pos = position == 'F' || position == 'D' ? position : %w[F D]
    def_pos = pos == %w[F D] ? 'Any' : pos
    return pos, def_pos
  end
end
