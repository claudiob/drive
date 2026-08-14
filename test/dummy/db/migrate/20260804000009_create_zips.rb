# Creates the zips table and backfills it from db/zips.txt.
class CreateZIPs < ActiveRecord::Migration[8.1]
  # id|county_id|code|city|time_zone for every ZIP the host app knows.
  ZIPS = 'db/zips.txt'

  # One statement per batch: 40,000 rows in a single insert is a needless risk.
  BATCH = 5_000

  def change
    create_table :zips do |t|
      t.string :code, null: false, limit: 5, index: { unique: true }
      t.string :city, null: false
      t.string :time_zone, null: false
      t.references :county, null: false, foreign_key: true
      t.references :market, foreign_key: true

      t.check_constraint "code GLOB '[0-9][0-9][0-9][0-9][0-9]'", name: 'zips_code_five_digits'
      t.timestamps
    end

    reversible { |direction| direction.up { backfill } }
  end

private

  def backfill
    rows = File.readlines Rails.root.join(ZIPS), chomp: true
    rows.each_slice(BATCH) { |slice| insert slice }
  end

  def insert(lines)
    values = lines.map do |line|
      id, county_id, code, city, time_zone = line.split '|'
      "(#{id}, #{county_id}, #{quote code}, #{quote city}, #{quote time_zone}, " \
        'current_timestamp, current_timestamp)'
    end

    execute <<~SQL.squish
      insert into zips (id, county_id, code, city, time_zone, created_at, updated_at)
      values #{values.join ', '}
    SQL
  end
end
