class CreateGoalies < ActiveRecord::Migration[5.1]
  def change
    create_table :goalies do |t|
      t.string :first_name
      t.string :last_name
      t.string :position
      t.string :team
      t.integer :number
      t.integer :wins
      t.integer :shutouts

      t.timestamps
    end
  end
end
