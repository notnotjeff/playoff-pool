class AddDefaultValueToRoundTotal < ActiveRecord::Migration[5.1]
  def change
    change_column :roster_players, :round_total, :integer, :default => 0
  end
end
