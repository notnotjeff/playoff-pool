namespace :daily_functions do
  # Have this check once a day at noon before any games are played to see if new round will start that day so lineups get locked
  desc "Check if the current round has changed and set accordingly"
  task :set_round => :environment do
    message = Scraper.games_today? ? Round.set_round : "There are no games today. Waiting until start of next round to change"
    puts message
  end

  desc "Update games being played or already played on selected date"
  task :update_stats => :environment do
    if Time.now < "11:00:00".to_time # In Heroku's timezone, its 7AM EST
      date = 12.hours.ago.to_datetime
    else
      date = Time.now.to_datetime
    end
    rounds = Round.get_rounds_hash

    puts "Starting Daily Scrape for #{date.strftime("%m-%d-%y")}..."
    Scraper.update_day_of_games("#{date.strftime("%Y-%m-%d")}")
    League.all.update_all(scraped_at: Time.now)
    puts "Ending Daily Scrape for #{date.strftime("%m-%d-%y")}"
  end

  desc "Scrape the games played the previous week to fix any statistical changes"
  task :scrape => :environment do
    start_date = 12.hours.ago.to_date
    start_date = 7.days.ago.to_date
    Player.seed # Make sure all players exist so new callups don't break everything

    puts "Starting Daily Scrape for #{date.strftime("%m-%d-%y")}..."
    Scraper.scrape_range_of_dates("#{start_date.strftime("%Y-%m-%d")}", "#{end_date.strftime("%Y-%m-%d")}")
    puts "Ending Daily Scrape for #{date.strftime("%m-%d-%y")}"
  end
end
