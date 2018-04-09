class CreateGeneralManagers < ActiveRecord::Migration[5.1]
  def change
    create_table :general_managers do |t|
      t.string :name
      t.integer :user_id, index: true
      t.integer :league_id, index: true

      t.timestamps
    end
  end
end
