class CreateSkaterGameStatlines < ActiveRecord::Migration[5.1]
  def change
    create_table :skater_game_statlines do |t|
      t.integer :skater_id
      t.string :team
      t.string :position
      t.string :opposition
      t.integer :round
      t.integer :goals
      t.integer :assists
      t.integer :points
      t.integer :game_winning_goals

      t.timestamps
    end
  end
end
