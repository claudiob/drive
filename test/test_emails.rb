require 'test_helper'

# How the dummy app stores an email: citext for an address, string for ciphertext.
class TestEmails < Minitest::Test
  def test_a_plaintext_email_column_is_citext
    assert_equal :citext, Market.columns_hash['email'].type
  end

  def test_an_encrypted_email_column_stays_a_string
    assert_includes Contact.encrypted_attributes, :email
    assert_equal :string, Contact.columns_hash['email'].type
  end

  def test_an_encrypted_email_normalizes_case_in_rails_rather_than_the_column
    assert Contact.type_for_attribute(:email).downcase?
  end
end
