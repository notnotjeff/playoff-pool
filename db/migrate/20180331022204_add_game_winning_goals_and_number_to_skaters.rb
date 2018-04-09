class AddGameWinningGoalsAndNumberToSkaters < ActiveRecord::Migration[5.1]
  def change
    add_column :skaters, :number, :string
    add_column :skaters, :game_winning_goals, :integer
    add_column :skaters, :games_played, :integer
  end
end
