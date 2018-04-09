class AddIndexToRosterPlayer < ActiveRecord::Migration[5.1]
  def change
    add_index :roster_players, [:player_id, :round]
  end
end
