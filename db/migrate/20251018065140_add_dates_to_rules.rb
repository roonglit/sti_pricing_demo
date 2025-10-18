class AddDatesToRules < ActiveRecord::Migration[8.1]
  def change
    add_column :rules, :starts_at, :datetime
    add_column :rules, :ends_at, :datetime
  end
end
