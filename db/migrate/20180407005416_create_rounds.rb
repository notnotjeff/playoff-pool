class CreateRounds < ActiveRecord::Migration[5.1]
  def change
    create_table :rounds do |t|
      t.boolean :current_round
      t.boolean :lineup_changes_allowed
      t.date :start_date
      t.date :end_date
      t.integer :round_number
      t.string :name

      t.timestamps
    end
  end
end
