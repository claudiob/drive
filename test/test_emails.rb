require 'test_helper'

# How the dummy app stores an email: citext for an address, string for ciphertext.
class TestEmails < Minitest::Test
  def test_a_plaintext_email_column_is_citext
    assert_equal :citext, Market.columns_hash['email'].type
  end

  def test_an_encrypted_email_column_stays_a_string
    [Agent, Contact].each do |model|
      assert_includes model.encrypted_attributes, :email
      assert_equal :string, model.columns_hash['email'].type
    end
  end

  def test_an_encrypted_email_normalizes_case_in_rails_rather_than_the_column
    [Agent, Contact].each do |model|
      assert model.type_for_attribute(:email).downcase?
    end
  end
end
