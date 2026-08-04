# Creates the counties table and backfills every county of the United States.
class CreateCounties < ActiveRecord::Migration[8.1]
  # Every county as fips|name|state_fips, from the Census national_county file.
  COUNTIES = 'db/counties.txt'

  def change
    create_table :counties do |t|
      t.string :fips, null: false, limit: 5, index: { unique: true }
      t.string :name, null: false
      t.references :state, null: false, foreign_key: true

      t.timestamps
    end

    add_check_constraint :counties, "fips ~ '^[0-9]{5}$'", name: 'counties_fips_five_digits'

    reversible { |direction| direction.up { backfill } }
  end

private

  def backfill
    state_ids = select_all('select fips, id from states').rows.to_h
    values = File.readlines(Rails.root.join(COUNTIES), chomp: true).map do |line|
      fips, name, state_fips = line.split '|'
      "(#{quote fips}, #{quote name}, #{state_ids.fetch state_fips}, now(), now())"
    end

    execute <<~SQL.squish
      insert into counties (fips, name, state_id, created_at, updated_at)
      values #{values.join ', '}
    SQL
  end
end
