# Gives the app a form with a foreign key to pick, which counties no longer offers.
class AddStateToMarkets < ActiveRecord::Migration[8.1]
  def change
    add_reference :markets, :state, null: false, foreign_key: true
  end
end
