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

  # The plugin builds the hidden input Rails reads from `data-bs-name`, so there
  # is no `name=` on the toggle and no text field for the foreign key at all.
  def test_a_belongs_to_column_becomes_a_combobox_of_names
    session = ActionDispatch::Integration::Session.new Rails.application
    session.get '/counties/new'
    body = session.response.body

    assert_includes body, "data-bs-toggle='combobox' data-bs-name='county[state_id]'"
    assert_includes body, "data-bs-value='#{State.find_by!(code: 'AL').id}'>Alabama</button>"
    refute_includes body, 'name="county[state_id]"'
  end
end
