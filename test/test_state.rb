require 'test_helper'

# The dummy app's State model, and the list its migration backfilled.
class TestState < Minitest::Test
  def test_the_migration_backfilled_the_fifty_states_and_dc
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

  def test_invalid_without_a_code_a_fips_or_a_name
    state = State.new

    refute_predicate state, :valid?
    assert_includes state.errors[:code], "can't be blank"
    assert_includes state.errors[:fips], "can't be blank"
    assert_includes state.errors[:name], "can't be blank"
  end

  def test_invalid_when_the_code_is_taken
    refute_predicate State.new(code: 'CA', fips: '99', name: 'Testland'), :valid?
  end

  def test_invalid_when_the_fips_is_taken
    refute_predicate State.new(code: 'ZZ', fips: '06', name: 'Testland'), :valid?
  end

  def test_invalid_when_the_name_is_taken
    refute_predicate State.new(code: 'ZZ', fips: '99', name: 'California'), :valid?
  end

  def test_invalid_when_the_code_is_not_two_capital_letters
    refute_predicate State.new(code: 'C', fips: '99', name: 'Testland'), :valid?
    refute_predicate State.new(code: 'ca', fips: '99', name: 'Testland'), :valid?
  end

  def test_invalid_when_the_fips_is_not_two_digits
    refute_predicate State.new(code: 'ZZ', fips: '6', name: 'Testland'), :valid?
    refute_predicate State.new(code: 'ZZ', fips: 'ab', name: 'Testland'), :valid?
  end

  def test_the_database_rejects_a_duplicate_code
    assert_raises ActiveRecord::RecordNotUnique do
      State.new(code: 'CA', fips: '99', name: 'Testland').save! validate: false
    end
  end

  def test_the_database_rejects_a_fips_that_is_not_two_digits
    assert_raises ActiveRecord::StatementInvalid do
      State.new(code: 'ZZ', fips: 'ab', name: 'Testland').save! validate: false
    end
  end
end
