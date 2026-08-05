require 'test_helper'

# The list the states migration backfilled.
class TestState < Minitest::Test
  def test_it_backfilled_the_fifty_states_and_dc
    assert_equal 51, State.count
  end

  def test_it_stores_the_official_code_fips_and_name
    california = State.find_by code: 'CA'

    assert_equal '06', california.fips
    assert_equal 'California', california.name
  end

  def test_it_keeps_the_leading_zero_on_a_fips_code
    assert_equal '01', State.find_by(code: 'AL').fips
  end

  def test_it_includes_the_district_of_columbia
    assert_equal 'District of Columbia', State.find_by(code: 'DC').name
  end

  def test_it_excludes_the_territories
    refute_predicate State.where(code: %w[PR GU VI AS MP UM]), :exists?
  end
end
