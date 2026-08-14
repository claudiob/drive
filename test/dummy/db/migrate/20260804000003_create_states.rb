# Creates the states table and backfills it from db/states.txt.
class CreateStates < ActiveRecord::Migration[8.1]
  # id|code|fips|name for every state the host app knows.
  STATES = 'db/states.txt'

  def change
    create_table :states do |t|
      t.string :code, null: false, limit: 2, index: { unique: true }
      t.string :fips, null: false, limit: 2, index: { unique: true }
      t.string :name, null: false, index: { unique: true }

      t.timestamps
    end

    add_check_constraint :states, "code GLOB '[A-Z][A-Z]'", name: 'states_code_two_letters'
    add_check_constraint :states, "fips GLOB '[0-9][0-9]'", name: 'states_fips_two_digits'

    reversible { |direction| direction.up { backfill } }
  end

private

  # Ids come from the file, so counties can point at them by number.
  def backfill
    values = File.readlines(Rails.root.join(STATES), chomp: true).map do |line|
      id, code, fips, name = line.split '|'
      "(#{id}, #{quote code}, #{quote fips}, #{quote name}, current_timestamp, current_timestamp)"
    end

    execute <<~SQL.squish
      insert into states (id, code, fips, name, created_at, updated_at)
      values #{values.join ', '}
    SQL
  end
end
