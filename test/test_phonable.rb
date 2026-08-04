require 'test_helper'

# The Phonable concern, exercised through Contact, the model that includes it.
class TestPhonable < Minitest::Test
  def setup
    Contact.delete_all
  end

  def test_it_strips_everything_that_is_not_a_digit
    contact = Contact.new phone: '(555) 223-4567'

    assert_equal '5552234567', contact.phone
  end

  def test_it_drops_a_leading_country_code
    contact = Contact.new phone: '+1 555 223 4567'

    assert_equal '5552234567', contact.phone
  end

  def test_it_leaves_a_nil_phone_alone
    assert_nil Contact.new(phone: nil).phone
  end

  def test_it_rejects_fewer_than_ten_digits
    contact = Contact.new phone: '555223456'

    refute_predicate contact, :valid?
    assert_includes contact.errors[:phone], 'is not a valid phone number'
  end

  def test_it_rejects_more_than_ten_digits
    refute_predicate Contact.new(phone: '55522345678'), :valid?
  end

  def test_it_rejects_an_area_code_starting_with_one_or_zero
    refute_predicate Contact.new(phone: '0552234567'), :valid?
    refute_predicate Contact.new(phone: '1552234567'), :valid?
  end

  def test_it_rejects_an_exchange_code_starting_with_one_or_zero
    refute_predicate Contact.new(phone: '5550234567'), :valid?
    refute_predicate Contact.new(phone: '5551234567'), :valid?
  end

  def test_the_database_rejects_a_phone_that_is_not_ten_digits
    contact = Contact.new phone: '5552'

    assert_raises ActiveRecord::StatementInvalid do
      contact.save! validate: false
    end
  end
end
