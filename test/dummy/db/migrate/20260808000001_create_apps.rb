# Creates the apps table: an integration the host app has connected, which a
# booking can be routed through and a contact can arrive from.
class CreateApps < ActiveRecord::Migration[8.1]
  def change
    create_table :apps do |t|
      t.string :name, null: false, index: { unique: true }
      # The id the external system knows this integration by: a name ending in
      # `id` without being a foreign key, which the seed generator fills with digits.
      t.string :uid
      t.text :webhook_url
      t.references :agent, foreign_key: true
      t.integer :bookings_count, default: 0, null: false

      t.timestamps
    end
  end
end
