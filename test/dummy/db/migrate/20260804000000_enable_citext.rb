# Enables citext, the case-insensitive text type every email column is stored in.
class EnableCitext < ActiveRecord::Migration[8.1]
  def change
    enable_extension 'citext'
  end
end
