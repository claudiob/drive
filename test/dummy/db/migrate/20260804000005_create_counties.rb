# Creates the counties table and backfills it from db/counties.txt.
class CreateCounties < ActiveRecord::Migration[8.1]
  # id|state_id|fips|name for every county the host app knows.
  COUNTIES = 'db/counties.txt'

  def change
    create_table :counties do |t|
      t.string :fips, null: false, limit: 5, index: { unique: true }
      t.string :name, null: false
      t.references :state, null: false, foreign_key: true

      t.timestamps
    end

    add_check_constraint :counties, "fips GLOB '[0-9][0-9][0-9][0-9][0-9]'",
                         name: 'counties_fips_five_digits'

    reversible { |direction| direction.up { backfill } }
  end

private

  def backfill
    values = File.readlines(Rails.root.join(COUNTIES), chomp: true).map do |line|
      id, state_id, fips, name = line.split '|'
      "(#{id}, #{state_id}, #{quote fips}, #{quote name}, current_timestamp, current_timestamp)"
    end

    execute <<~SQL.squish
      insert into counties (id, state_id, fips, name, created_at, updated_at)
      values #{values.join ', '}
    SQL
  end
end
