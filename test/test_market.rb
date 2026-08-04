require 'test_helper'

# The dummy app's Market model: a name and nothing else.
class TestMarket < Minitest::Test
  def setup
    Market.delete_all
  end

  def test_valid_with_a_name
    assert_predicate Market.new(name: 'Boston'), :valid?
  end

  def test_invalid_without_a_name
    market = Market.new

    refute_predicate market, :valid?
    assert_includes market.errors[:name], "can't be blank"
  end

  def test_invalid_when_the_name_is_taken
    Market.create! name: 'Boston'

    refute_predicate Market.new(name: 'Boston'), :valid?
  end

  def test_the_database_rejects_a_missing_name
    assert_raises ActiveRecord::NotNullViolation do
      Market.new.save! validate: false
    end
  end

  def test_the_database_rejects_a_duplicate_name
    Market.create! name: 'Boston'

    assert_raises ActiveRecord::RecordNotUnique do
      Market.new(name: 'Boston').save! validate: false
    end
  end
end
