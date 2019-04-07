# frozen_string_literal: true

class StaticPagesController < ApplicationController
  def home
    redirect_to current_user if user_signed_in?
  end

  def updater
    Scraper.update_day_of_games('2018-04-14')
  end
end
