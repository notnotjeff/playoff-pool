class AddOtGoalsToSkaterGameStatlines < ActiveRecord::Migration[5.1]
  def change
    add_column :skater_game_statlines, :ot_goals, :integer
  end
end
