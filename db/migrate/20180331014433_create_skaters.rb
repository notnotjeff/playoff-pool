class CreateSkaters < ActiveRecord::Migration[5.1]
  def change
    create_table :skaters do |t|
      t.string :first_name
      t.string :last_name
      t.string :position
      t.string :team
      t.integer :goals
      t.integer :assists
      t.integer :points
      t.integer :team_id

      t.timestamps
    end
  end
end
