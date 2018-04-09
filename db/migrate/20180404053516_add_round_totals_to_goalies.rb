class AddRoundTotalsToGoalies < ActiveRecord::Migration[5.1]
  def change
    add_column :goalies, :r1_wins, :integer
    add_column :goalies, :r1_shutouts, :integer
    add_column :goalies, :r2_wins, :integer
    add_column :goalies, :r2_shutouts, :integer
    add_column :goalies, :r3_wins, :integer
    add_column :goalies, :r3_shutouts, :integer
    add_column :goalies, :r4_wins, :integer
    add_column :goalies, :r4_shutouts, :integer
    add_column :goalies, :r1_total, :integer
    add_column :goalies, :r2_total, :integer
    add_column :goalies, :r3_total, :integer
    add_column :goalies, :r4_total, :integer
  end
end
