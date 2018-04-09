class AddRoundTotalsToSkaters < ActiveRecord::Migration[5.1]
  def change
    add_column :skaters, :r1_goals, :integer
    add_column :skaters, :r1_assists, :integer
    add_column :skaters, :r1_points, :integer
    add_column :skaters, :r1_game_winning_goals, :integer
    add_column :skaters, :r2_goals, :integer
    add_column :skaters, :r2_assists, :integer
    add_column :skaters, :r2_points, :integer
    add_column :skaters, :r2_game_winning_goals, :integer
    add_column :skaters, :r3_goals, :integer
    add_column :skaters, :r3_assists, :integer
    add_column :skaters, :r3_points, :integer
    add_column :skaters, :r3_game_winning_goals, :integer
    add_column :skaters, :r4_goals, :integer
    add_column :skaters, :r4_assists, :integer
    add_column :skaters, :r4_points, :integer
    add_column :skaters, :r4_game_winning_goals, :integer
  end
end
