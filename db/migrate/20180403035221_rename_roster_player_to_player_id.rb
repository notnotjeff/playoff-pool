class RenameRosterPlayerToPlayerId < ActiveRecord::Migration[5.1]
  def change
    rename_column :roster_players, :skater_id, :player_id
  end
end
