class AddRoundPlayerCountsToLeagues < ActiveRecord::Migration[5.1]
  def change
    add_column :leagues, :r1_fw_count, :integer
    add_column :leagues, :r2_fw_count, :integer
    add_column :leagues, :r3_fw_count, :integer
    add_column :leagues, :r4_fw_count, :integer
    add_column :leagues, :r1_d_count, :integer
    add_column :leagues, :r2_d_count, :integer
    add_column :leagues, :r3_d_count, :integer
    add_column :leagues, :r4_d_count, :integer
    add_column :leagues, :r1_g_count, :integer
    add_column :leagues, :r2_g_count, :integer
    add_column :leagues, :r3_g_count, :integer
    add_column :leagues, :r4_g_count, :integer
  end
end
