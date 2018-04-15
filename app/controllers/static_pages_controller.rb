class StaticPagesController < ApplicationController
  def home
    if user_signed_in?
      redirect_to current_user
    end
  end

  def updater
    Scraper.update_day_of_games("2018-04-14")
  end
end
