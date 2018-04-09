class AddRoundFinishedBooleanToRounds < ActiveRecord::Migration[5.1]
  def change
    add_column :rounds, :round_finished, :boolean
  end
end
