# Adds the name agents are labeled by, deriving one for any agent already stored.
class AddNameToAgents < ActiveRecord::Migration[8.1]
  def up
    add_column :agents, :name, :string
    Agent.reset_column_information
    # The email is encrypted, so only the model can read it to derive a name.
    Agent.find_each(&:save!)
    change_column_null :agents, :name, false
  end

  def down
    remove_column :agents, :name
  end
end
