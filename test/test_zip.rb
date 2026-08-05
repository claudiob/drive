require 'test_helper'

# The list the zips migration backfilled, and how it joined to counties.
class TestZIP < Minitest::Test
  def test_it_backfilled_every_zip
    assert_equal 40_965, ZIP.count
  end

  def test_it_stores_the_city_and_the_county_the_zip_mostly_belongs_to
    zip = ZIP.find_by code: '90210'

    assert_equal 'Beverly Hills', zip.city
    assert_equal 'Los Angeles County', zip.county.name
    assert_equal 'CA', zip.county.state.code
  end

  def test_it_keeps_the_leading_zeros_on_a_code
    assert_equal 'Holtsville', ZIP.find_by(code: '00501').city
  end

  # The source mixes Rails zone names with IANA identifiers; both must resolve,
  # or Time.use_zone raises on whichever rows carry the other kind.
  def test_every_time_zone_resolves
    zones = ZIP.distinct.pluck :time_zone

    assert_operator zones.size, :>, 20
    zones.each { |zone| assert ActiveSupport::TimeZone[zone], "#{zone} does not resolve" }
  end

  def test_it_holds_no_leftovers_from_the_seed_files
    assert_empty ZIP.where 'city ilike ?', '%HouseAccount%'
  end
end
