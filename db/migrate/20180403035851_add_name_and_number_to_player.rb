class AddNameAndNumberToPlayer < ActiveRecord::Migration[5.1]
  def change
    add_column :players, :first_name, :string
    add_column :players, :last_name, :string
    add_column :players, :number, :integer
  end
end
