# frozen_string_literal: true

class League < ApplicationRecord
  has_many :general_managers, dependent: :destroy
  belongs_to :user
  validates :name, length: { maximum: 50 }
  before_create :playoffs_started?

  def skaters
    general_managers.joins(:roster_players).select('roster_players.player_id AS id').where("roster_players.position != 'G'")
  end

  def goalies
    general_managers.joins(:roster_players).select('roster_players.player_id AS id').where("roster_players.position = 'G'")
  end

  def teams
    general_managers.joins({:roster_players => :player}).order('team ASC').select('players.team AS team').distinct.pluck(:team)
  end

  private

  def playoffs_started?
    throw :abort if Round.current_round.positive?
  end
end
