class AddOtGoalsToSkaters < ActiveRecord::Migration[5.1]
  def change
    add_column :skaters, :r1_ot_goals, :integer
    add_column :skaters, :r2_ot_goals, :integer
    add_column :skaters, :r3_ot_goals, :integer
    add_column :skaters, :r4_ot_goals, :integer
  end
end
