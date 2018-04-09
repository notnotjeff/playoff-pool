class Player < ApplicationRecord
  has_many :roster_players
  has_many :general_managers, :through => :roster_players

  scope :forwards, -> { where(position: ["C", "LW", "RW", "L", "R"]) }
  scope :defensemen, -> { where(position: "D") }
  scope :goalies, -> { where(position: "G") }

  def full_name
    return "#{first_name} #{last_name}"
  end

  def name_last_first
    return "#{last_name}, #{first_name}"
  end

  def statline
    if position == "G"
      Goalie.find(self.skater_id)
    else
      Skater.find(self.skater_id)
    end
  end

  def position_category
    unless position == "G" || position == "D"
      return "F"
    end

    return position
  end
end
