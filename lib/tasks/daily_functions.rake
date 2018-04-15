namespace :daily_functions do
  desc "Check if the current round has changed and set accordingly"
  task :set_round => :environment do
    message = Round.set_round
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
    puts "Ending Daily Scrape for #{date.strftime("%m-%d-%y")}"
  end

  desc "Scrape the games played on the previous day"
  task :scrape => :environment do
    date = 12.hours.ago.to_datetime
    Player.seed # Make sure all players exist so new callups don't break everything

    puts "Starting Daily Scrape for #{date.strftime("%m-%d-%y")}..."
    Scraper.update_day_of_games("#{date.strftime("%Y-%m-%d")}")
    puts "Ending Daily Scrape for #{date.strftime("%m-%d-%y")}"
  end
end
