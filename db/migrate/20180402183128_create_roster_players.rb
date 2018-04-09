class CreateRosterPlayers < ActiveRecord::Migration[5.1]
  def change
    create_table :roster_players do |t|
      t.integer :general_manager_id, index: true
      t.integer :skater_id, index: true
      t.integer :league_id, index: true
      t.integer :round
      t.string :position

      t.timestamps
    end
  end
end
