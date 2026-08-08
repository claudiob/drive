# Creates the specialties table: what a provider does and what a booking asks
# for. The name is indexed for the search box, but not uniquely — two
# franchises might each offer one with the same name.
class CreateSpecialties < ActiveRecord::Migration[8.1]
  def change
    create_table :specialties do |t|
      t.string :name, null: false, index: true
      t.integer :bookings_count, default: 0, null: false

      t.timestamps
    end
  end
end
