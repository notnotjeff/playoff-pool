class CreateGoalieGameStatlines < ActiveRecord::Migration[5.1]
  def change
    create_table :goalie_game_statlines do |t|
      t.integer :skater_id
      t.string :team
      t.string :position
      t.string :opposition
      t.integer :round
      t.integer :win
      t.integer :shutout
      t.date :game_date
      t.integer :game_id

      t.timestamps
    end
  end
end
