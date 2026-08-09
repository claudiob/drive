require 'test_helper'
require 'action_dispatch/testing/integration'

# Encrypted columns never reach a page the gem builds for itself.
class TestRecoursesPii < Minitest::Test
  def setup
    Booking.delete_all
    Message.delete_all
    Contact.delete_all
    @session = ActionDispatch::Integration::Session.new Rails.application
  end

  # The column list is the single place PII is dropped, and it asks the model
  # rather than a record — so no row's contents can put an encrypted column back.
  def test_the_generic_columns_leave_out_every_encrypted_attribute
    columns = Admin::ContactsController.new.view_context.resource_columns

    assert_includes columns, 'name'
    %w[phone email surname].each { |column| refute_includes columns, column }
  end

  # /contacts shows Phone because the dummy app's own _row asks for it. Email and
  # surname are in no row partial, so they stay off the page either way.
  def test_encrypted_values_no_row_asks_for_stay_off_the_page
    Contact.create! phone: '5552234567', email: 'ada@example.com', surname: 'Lovelace'
    visit_index

    ['Email', 'Surname', 'ada@example.com', 'Lovelace'].each do |value|
      refute_includes body, value
    end
  end

  # A phone is the only thing a contact can be searched by, and it is encrypted, so
  # the box asks for a whole one. What it asks for is a prompt, never a value.
  def test_an_encrypted_column_is_searched_whole
    visit_index

    assert_includes body, 'name="q[phone_eq]"'
    assert_includes body, 'placeholder="Filter by exact phone"'
  end

  def test_that_holds_for_a_row_stored_as_plaintext_too
    insert_plaintext_contact
    visit_index

    ['plain@example.com', 'Plaintext'].each { |value| refute_includes body, value }
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
