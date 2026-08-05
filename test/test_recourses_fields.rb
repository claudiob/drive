require 'test_helper'
require 'action_dispatch/testing/integration'

# Which field a column gets, and the HTML that constrains it.
class TestRecoursesFields < Minitest::Test
  def test_a_required_email_shows_an_example_address
    session = ActionDispatch::Integration::Session.new Rails.application
    session.get '/markets/new'

    assert_match %r{placeholder="michael@example\.com"[^>]*name="market\[email\]"},
                 session.response.body
  end
end
