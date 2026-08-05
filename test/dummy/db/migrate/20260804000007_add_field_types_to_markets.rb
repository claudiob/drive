# Gives the dummy app one column of each kind a form field is chosen by.
class AddFieldTypesToMarkets < ActiveRecord::Migration[8.1]
  def change
    change_table :markets, bulk: true do |t|
      t.citext :email
      t.string :color
      t.string :zip, limit: 5
      t.date :opens_on
      t.time :opens_at
    end
  end
end
