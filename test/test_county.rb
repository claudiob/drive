require 'test_helper'

# The list the counties migration backfilled, and how it joined to states.
class TestCounty < Minitest::Test
  def test_it_backfilled_every_county
    assert_equal 3143, County.count
  end

  def test_it_stores_the_official_fips_and_name
    assert_equal 'Los Angeles County', County.find_by(fips: '06037').name
  end

  # The backfill looks each state up by FIPS, so a wrong join lands here.
  def test_every_county_belongs_to_the_state_its_fips_starts_with
    mismatched = County.joins(:state).where 'left(counties.fips, 2) <> states.fips'

    assert_empty mismatched
  end

  def test_it_counts_the_counties_a_state_is_known_for
    assert_equal 254, State.find_by(code: 'TX').counties.count
    assert_equal 3, State.find_by(code: 'DE').counties.count
    assert_equal 1, State.find_by(code: 'DC').counties.count
  end

  # Four names carry an apostrophe, which unquoted SQL would have mangled.
  def test_it_keeps_an_apostrophe_in_a_name
    assert_predicate County.where(name: "Prince George's County"), :any?
  end

  def test_names_repeat_across_states
    assert_operator County.where(name: 'Washington County').count, :>, 20
  end
end
