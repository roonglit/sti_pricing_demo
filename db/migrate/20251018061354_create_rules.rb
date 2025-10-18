class CreateRules < ActiveRecord::Migration[8.1]
  def change
    create_table :rules do |t|
      t.string :name
      t.string :type, null: false       # STI discriminator column
      t.json :properties, default: {}   # Store rule-specific properties
      t.boolean :active, default: true  # Enable/disable rules

      t.timestamps
    end
  end
end
