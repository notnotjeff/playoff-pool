class CreatePlayers < ActiveRecord::Migration[5.1]
  def change
    create_table :players do |t|
      t.integer :skater_id
      t.string :position
      t.string :team

      t.timestamps
    end
  end
end
