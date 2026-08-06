# Creates the specialties table and fills it with the trades fountain works in, so an
# app never starts with an empty one. The names live beside this file, the way the
# states and the counties do.
class CreateSpecialties < ActiveRecord::Migration[8.1]
  # Every trade, one per line. The icon is chosen afterwards, per specialty.
  NAMES = Rails.root.join('db/specialties.txt').readlines chomp: true

  def up
    create_table :specialties do |t|
      t.string :name, null: false, index: { unique: true }
      t.string :icon

      t.timestamps
    end

    now = Time.current
    Specialty.insert_all(NAMES.map { |name| { name:, created_at: now, updated_at: now } })
  end

  def down
    drop_table :specialties
  end
end
