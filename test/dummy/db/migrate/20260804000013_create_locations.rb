# Creates the locations table: a ZIP is required, a source and an agent are not.
class CreateLocations < ActiveRecord::Migration[8.1]
  def change
    create_table :locations do |t|
      t.string :street
      t.string :city
      t.references :zip, null: false, foreign_key: true
      t.references :source, foreign_key: true
      t.references :agent, foreign_key: true

      t.timestamps
    end
  end
end
