class AddScrapedAtToLeagues < ActiveRecord::Migration[5.1]
  def change
    add_column :leagues, :scraped_at, :datetime
  end
end
