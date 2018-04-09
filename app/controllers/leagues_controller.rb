class LeaguesController < ApplicationController
  protect_from_forgery

  before_action :user_signed_in?, only: [:new, :create, :destroy]
  before_action :correct_user, only: :destroy

  def index
    @leagues = League.all
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

  private

    def league_params
      params.require(:league).permit(:name, :r1_fw_count, :r1_d_count, :r1_g_count, :r2_fw_count, :r2_d_count, :r2_g_count, :r3_fw_count, :r3_d_count, :r3_g_count, :r4_fw_count, :r4_d_count, :r4_g_count)
    end

    def correct_user
      @league = current_user.leagues.find_by(id: params[:id])
      redirect_to root_url if @league.nil?
    end
end
