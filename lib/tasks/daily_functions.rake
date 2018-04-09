namespace :daily_functions do
  desc "Check if the current round has changed and set accordingly"
  task :set_round => :environment do
    Round.set_round
  end

  desc "Scrape the games played on the previous day"
  task :scrape => :environment do
    date = 12.hours.ago.to_datetime
    puts "Starting Daily Scrape for #{date.strftime("%m-%d-%y")}..."
    SkaterGameStatline.scrape_todays_games("#{date.strftime("%Y-%m-%d")}")
    GoalieGameStatline.scrape_todays_games("#{date.strftime("%Y-%m-%d")}")
    GeneralManager.update_round(Round.current_round) if Round.current_round > 0
    puts "Ending Daily Scrape for #{date.strftime("%m-%d-%y")}"
  end
end
