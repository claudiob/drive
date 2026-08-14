require 'test_helper'
require 'action_dispatch/testing/integration'

# The field a text column gets: room to grow long without starting big.
class TestRecoursesTextareas < Minitest::Test
  def test_a_text_column_gets_a_one_row_textarea
    session = ActionDispatch::Integration::Session.new Rails.application
    session.get '/messages/new'

    assert_match %r{<textarea [^>]*rows="1"[^>]*name="message\[content\]"}, session.response.body
  end
end
