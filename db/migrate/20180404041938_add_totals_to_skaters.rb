class AddTotalsToSkaters < ActiveRecord::Migration[5.1]
  def change
    add_column :skaters, :r1_total, :integer
    add_column :skaters, :r2_total, :integer
    add_column :skaters, :r3_total, :integer
    add_column :skaters, :r4_total, :integer
  end
end
