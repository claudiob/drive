require 'test_helper'
require 'action_dispatch/testing/integration'

# How a datetime reads on a page, and what it carries for a machine.
class TestRecoursesTimes < Minitest::Test
  def setup
    Contact.delete_all
    @session = ActionDispatch::Integration::Session.new Rails.application
  end

  def test_it_wraps_a_time_in_a_time_tag_carrying_the_machine_readable_value
    contact = Contact.create! phone: '5552234567'
    visit_index

    assert_includes body, "<time datetime=\"#{contact.created_at.rfc3339}\">"
  end

  def test_it_reads_a_time_as_month_day_and_zone
    Contact.create! phone: '5552234567'
    visit_index

    assert_match(/<time [^>]+>[A-Z][a-z]{2} \d{1,2} at \d{2}:\d{2}[ap]m [A-Z]{3,4}</, body)
    refute_includes body, 'UTC'
  end

private

  def visit_index
    @session.get '/contacts'
  end

  def body
    @session.response.body
  end
end
