class Round < ApplicationRecord
  require 'open-uri'

  def self.seed_rounds
    Round.create!(name: "Round 1", round_number: 1, current_round: false, lineup_changes_allowed: true, round_finished: false, start_date: "11-04-2018".to_date, end_date: nil)
    Round.create!(name: "Round 2", round_number: 2, current_round: false, lineup_changes_allowed: false, round_finished: false, start_date: nil, end_date: nil)
    Round.create!(name: "Round 3", round_number: 3, current_round: false, lineup_changes_allowed: false, round_finished: false, start_date: nil, end_date: nil)
    Round.create!(name: "Round 4", round_number: 4, current_round: false, lineup_changes_allowed: false, round_finished: false, start_date: nil, end_date: nil)
  end

  def self.current_round
    r = Round.find_by(current_round: true)

    if !r
      return 0
    else
      return r.round_number
    end
  end

  def self.round_finished?(r)
    round = Round.find_by(round_number: r)
    if round && round.round_finished == true
      return true
    else
      return false
    end
  end

  def self.lineup_round
    r = Round.find_by(lineup_changes_allowed: true)
    if r
      return r.round_number
    else
      return false
    end
  end

  def self.change_round(round)
    Round.all.each do |r|
      if r.round_number < round
        r.current_round = false
        r.round_finished = true
      elsif r.round_number == round
        r.current_round = true
        r.round_finished = false
      else
        r.current_round = false
        r.round_finished = false
      end
      r.lineup_changes_allowed = false
      r.save
    end
    GeneralManager.update_round(round)
  end

  def self.open_lineups(round)
    Round.update_all(lineup_changes_allowed: false)

    r = Round.find_by(round_number: round)
    if r
      r.lineup_changes_allowed = true
      r.save
    end

    Round.update_round_player_pool(round)
  end

  def self.set_round
    rounds = Round.get_rounds_hash
    current_round = 1

    rounds.each do |t|
      current_round = t[1].count if t[1].count > current_round
    end

    if Round.current_round != current_round && Round.all.order(round_number: :asc).first.start_date <= Time.now
      Round.change_round(current_round)
      return "Changed round to #{current_round}"
    elsif Round.find_by(round_number: current_round).start_date && Round.find_by(round_number: current_round).start_date <= Time.now
      Round.change_round(current_round)
      return "Changed round to #{current_round}"
    end
    return "Round has not changed, it is still round #{current_round}"
  end

  def self.reset_league_rounds
    Round.all.each do |ro|
      ro.current_round = false
      ro.round_finished = false
      ro.lineup_changes_allowed = false
      ro.save
    end
    Round.open_lineups 1
  end

  def self.scrape_round(round)
    SkaterGameStatline.scrape_round(round)
    GoalieGameStatline.scrape_round(round)
    GeneralManager.update_round(round)
  end

  def self.update_round_player_pool(round)
    rounds = Round.get_rounds_hash
    rounds.each do |r_team|
      if r_team[1].count >= round
        Player.where(team: r_team[0].to_s).update_all(rounds: round)
      end
    end
  end

  def self.get_rounds_hash
    url = "https://statsapi.web.nhl.com/api/v1/tournaments/playoffs?site=en_nhl&expand=round.series,schedule.game.seriesSummary&season=20172018"
    doc = JSON.parse(Nokogiri::HTML(open(url)))
    rounds = {}

    return {} if doc["rounds"].nil?

    doc["rounds"].each do |round|
      round_number = round["number"].to_i
      round["series"].each do |series|
        next if series["names"]["teamAbbreviationA"] == "" || series["names"]["teamAbbreviationB"] == ""
        # If team doesn't exist in rounds then add it
        rounds[series["names"]["teamAbbreviationA"].to_sym] ||= {}
        rounds[series["names"]["teamAbbreviationB"].to_sym] ||= {}
        # Add opponent to rounds hash
        rounds[series["names"]["teamAbbreviationA"].to_sym][series["names"]["teamAbbreviationB"].to_sym] = round_number
        rounds[series["names"]["teamAbbreviationB"].to_sym][series["names"]["teamAbbreviationA"].to_sym] = round_number
      end
    end

    return rounds
  end
end
