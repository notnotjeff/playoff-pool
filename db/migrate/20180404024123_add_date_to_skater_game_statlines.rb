class AddDateToSkaterGameStatlines < ActiveRecord::Migration[5.1]
  def change
    add_column :skater_game_statlines, :game_date, :date
  end
end
