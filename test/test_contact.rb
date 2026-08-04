require 'test_helper'

# The dummy app's Contact model, which the gem's screens will read.
class TestContact < Minitest::Test
  def setup
    Contact.delete_all
  end

  def test_valid_with_only_a_phone
    assert_predicate Contact.new(phone: '5551234567'), :valid?
  end

  def test_email_name_and_surname_are_optional
    contact = Contact.create!(phone: '5551234567')

    assert_nil contact.email
    assert_nil contact.name
    assert_nil contact.surname
  end

  def test_accepts_an_email_a_name_and_a_surname
    contact = Contact.create!(phone: '5551234567', email: 'ada@example.com',
                              name: 'Ada', surname: 'Lovelace')

    assert_equal 'ada@example.com', contact.email
    assert_equal 'Ada', contact.name
    assert_equal 'Lovelace', contact.surname
  end

  def test_invalid_without_a_phone
    contact = Contact.new

    refute_predicate contact, :valid?
    assert_includes contact.errors[:phone], "can't be blank"
  end

  def test_invalid_when_phone_is_not_ten_digits
    refute_predicate Contact.new(phone: '555123456'), :valid?
    refute_predicate Contact.new(phone: '55512345678'), :valid?
    refute_predicate Contact.new(phone: '555123456a'), :valid?
  end

  def test_invalid_when_phone_is_already_taken
    Contact.create!(phone: '5551234567')

    refute_predicate Contact.new(phone: '5551234567'), :valid?
  end

  def test_database_rejects_a_duplicate_phone
    Contact.create!(phone: '5551234567')

    assert_raises ActiveRecord::RecordNotUnique do
      Contact.new(phone: '5551234567').save!(validate: false)
    end
  end

  def test_database_rejects_a_missing_phone
    assert_raises ActiveRecord::NotNullViolation do
      Contact.new.save!(validate: false)
    end
  end
end
