# Creates the agents table. The email is encrypted, so it is a string, not citext.
class CreateAgents < ActiveRecord::Migration[8.1]
  def change
    create_table :agents do |t|
      t.string :email, null: false, index: { unique: true }

      t.timestamps
    end
  end
end
