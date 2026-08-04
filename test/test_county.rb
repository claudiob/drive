require 'test_helper'

# The dummy app's County model, and the list its migration backfilled.
class TestCounty < Minitest::Test
  def test_the_migration_backfilled_every_county
    assert_equal 3143, County.count
  end

  def test_it_stores_the_official_fips_and_name
    county = County.find_by fips: '06037'

    assert_equal 'Los Angeles County', county.name
  end

  def test_every_county_belongs_to_the_state_its_fips_starts_with
    mismatched = County.joins(:state).where 'left(counties.fips, 2) <> states.fips'

    assert_empty mismatched
  end

  def test_it_reaches_its_state_through_the_association
    assert_equal 'California', County.find_by(fips: '06037').state.name
  end

  def test_it_counts_the_counties_a_state_is_known_for
    assert_equal 254, State.find_by(code: 'TX').counties.count
    assert_equal 3, State.find_by(code: 'DE').counties.count
    assert_equal 1, State.find_by(code: 'DC').counties.count
  end

  def test_it_keeps_an_apostrophe_in_a_name
    assert_predicate County.where(name: "Prince George's County"), :any?
  end

  def test_names_repeat_across_states
    assert_operator County.where(name: 'Washington County').count, :>, 20
  end

  def test_invalid_without_a_fips_a_name_or_a_state
    county = County.new

    refute_predicate county, :valid?
    assert_includes county.errors[:fips], "can't be blank"
    assert_includes county.errors[:name], "can't be blank"
    assert_includes county.errors[:state], 'must exist'
  end

  def test_invalid_when_the_fips_is_taken
    assert_predicate County.new(fips: '06037', name: 'Copy', state: some_state), :invalid?
  end

  def test_invalid_when_the_fips_is_not_five_digits
    assert_predicate County.new(fips: '0603', name: 'Short', state: some_state), :invalid?
    assert_predicate County.new(fips: '0603x', name: 'Letter', state: some_state), :invalid?
  end

  def test_the_database_rejects_a_duplicate_fips
    county = County.new fips: '06037', name: 'Copy', state: some_state

    assert_raises ActiveRecord::RecordNotUnique do
      county.save! validate: false
    end
  end

  def test_the_database_rejects_a_state_that_does_not_exist
    county = County.new fips: '99999', name: 'Nowhere', state_id: 0

    assert_raises ActiveRecord::InvalidForeignKey do
      county.save! validate: false
    end
  end

private

  def some_state
    State.find_by code: 'CA'
  end
end
