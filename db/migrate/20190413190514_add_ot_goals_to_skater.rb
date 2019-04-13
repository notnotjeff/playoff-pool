class AddOtGoalsToSkater < ActiveRecord::Migration[5.1]
  def change
    add_column :skaters, :ot_goals, :integer
  end
end
