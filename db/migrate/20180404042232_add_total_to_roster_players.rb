class AddTotalToRosterPlayers < ActiveRecord::Migration[5.1]
  def change
    add_column :roster_players, :round_total, :integer
  end
end
