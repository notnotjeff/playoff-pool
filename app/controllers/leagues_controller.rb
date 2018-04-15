class LeaguesController < ApplicationController
  protect_from_forgery

  before_action :user_signed_in?, only: [:new, :create, :destroy]
  before_action :correct_user, only: :destroy

  def index
    @leagues = League.all.order(name: :asc)
  end

  def show
    @league = League.find(params[:id])
    @gms = GeneralManager.where(league_id: @league).order(points: :desc)
    @gm = @league.general_managers.build
  end

  def new
    @league = current_user.leagues.build
  end

  def create
    @league = current_user.leagues.build(league_params)
    if @league.save
  		flash[:success] = "League created!"
      current_user.teams.build(name: current_user.name, league_id: @league)
  		redirect_to @league
  	else
  		render 'league/create'
  	end
  end

  def destroy
    @league.destroy
    flash[:success] = "League deleted"
    redirect_to root_url
  end

  def skaters
    @round = set_round(params[:round].to_s)
    @position = set_position(params[:position].to_s)
    @league = League.find(params[:id].to_i)

    if @round.to_i.between?(1,4)
      @skaters = RosterPlayer.where(league_id: @league, round: @round, position: @position)
                              .order(round_total: :desc)
                              .select(:id, :player_id, :round, :round_total)
                              .group(:player_id, :id)
    else
      round_count = Round.current_round
      (1..round_count).each do |round|
        new_skaters = RosterPlayer.where(league_id: @league, position: @position)
                                  .order(round_total: :desc)
                                  .select(:id, :player_id, :round, :round_total)
                                  .group(:player_id, :id)
        @skaters = @skaters.nil? ? @skaters = new_skaters : @skaters.merge(new_skaters)
      end
    end
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
      return Round.current_round.to_i if round = ""
      return round.to_i.between?(0, 4) ? round : Round.current_round
    end

    def set_position(position)
      return ["F", "D"] if position == "Any" || position == ""
      return position == "F" || position == "D" ? position : "F"
    end
end
