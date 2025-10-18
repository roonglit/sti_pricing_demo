class AddPriorityToRules < ActiveRecord::Migration[8.1]
  def change
    add_column :rules, :priority, :integer, default: 0
    add_index :rules, :priority
  end
end
