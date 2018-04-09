class AddStatsToGeneralManagers < ActiveRecord::Migration[5.1]
  def change
    add_column :general_managers, :r1_points, :integer
    add_column :general_managers, :r2_points, :integer
    add_column :general_managers, :r3_points, :integer
    add_column :general_managers, :r4_points, :integer
    add_column :general_managers, :points, :integer
  end
end
