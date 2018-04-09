class AddIndexToSkaterGameStatlines < ActiveRecord::Migration[5.1]
  def change
    add_index :skater_game_statlines, [:skater_id, :round]
  end
end
