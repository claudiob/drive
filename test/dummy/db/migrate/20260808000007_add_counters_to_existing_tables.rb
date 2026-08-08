# Adds the counter cache columns the new resources need on the tables that
# already existed, and backfills the two counties and markets already carry
# rows for: 40,965 ZIPs exist before this migration ever runs.
class AddCountersToExistingTables < ActiveRecord::Migration[8.1]
  def change
    add_column :zips, :bookings_count, :integer, default: 0, null: false
    add_column :markets, :zips_count, :integer, default: 0, null: false
    add_column :counties, :zips_count, :integer, default: 0, null: false
    add_column :sources, :contacts_count, :integer, default: 0, null: false
    add_column :agents, :contacts_count, :integer, default: 0, null: false
    add_column :contacts, :bookings_count, :integer, default: 0, null: false
    add_reference :contacts, :app, foreign_key: true
    add_reference :contacts, :source, foreign_key: true
    add_reference :contacts, :agent, foreign_key: true

    reversible { |direction| direction.up { backfill } }
  end

private

  def backfill
    execute <<~SQL.squish
      update counties set zips_count = (
        select count(*) from zips where zips.county_id = counties.id
      )
    SQL
    execute <<~SQL.squish
      update markets set zips_count = (
        select count(*) from zips where zips.market_id = markets.id
      )
    SQL
  end
end
