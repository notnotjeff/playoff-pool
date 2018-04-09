class AddRoundsToPlayers < ActiveRecord::Migration[5.1]
  def change
    add_column :players, :rounds, :integer
  end
end
