require 'test_helper'
require 'action_dispatch/testing/integration'

# Encrypted columns must never reach the page, whatever a row happens to hold.
class TestRecoursesPii < Minitest::Test
  def setup
    Contact.delete_all
    @session = ActionDispatch::Integration::Session.new Rails.application
  end

  def test_the_table_leaves_out_encrypted_columns
    Contact.create! phone: '5552234567', email: 'ada@example.com', surname: 'Lovelace'
    visit_index

    %w[Phone Email Surname].each { |heading| refute_includes body, heading }
    ['5552234567', '555-223-4567', 'ada@example.com', 'Lovelace'].each do |value|
      refute_includes body, value
    end
  end

  # A row written before `encrypts` was added still holds plaintext, and
  # `encrypted_attribute?` answers false for it. The column list has to come from
  # the model, not from a per-row check, or that row's PII lands on the page.
  def test_it_hides_pii_columns_even_when_a_row_holds_plaintext
    insert_plaintext_contact
    visit_index

    ['plain@example.com', 'Plaintext', '5557770001'].each do |value|
      refute_includes body, value
    end
  end

private

  def visit_index
    @session.get '/contacts'
  end

  def body
    @session.response.body
  end

  def insert_plaintext_contact
    Contact.connection.execute <<~SQL.squish
      insert into contacts (phone, email, surname, created_at, updated_at)
      values ('5557770001', 'plain@example.com', 'Plaintext', now(), now())
    SQL
  end
end
