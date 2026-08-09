require 'test_helper'
require 'action_dispatch/testing/integration'

# Which field a column gets, and the HTML that constrains it.
class TestRecoursesFields < Minitest::Test
  def test_a_required_email_shows_an_example_address
    session = ActionDispatch::Integration::Session.new Rails.application
    session.get '/admin/markets/new'

    assert_match %r{placeholder="michael@example\.com"[^>]*name="market\[email\]"},
                 session.response.body
  end

  # The host's own `_fields` names both types, which beats the encrypted-column
  # rule, and the phone carries the only bracket class of any pattern in the app.
  def test_a_host_names_the_types_and_the_title_shows_the_format
    session = ActionDispatch::Integration::Session.new Rails.application
    session.get '/admin/contacts/new'
    body = session.response.body

    assert_includes body, 'pattern="[2-9]\d{2}-[2-9]\d{2}-\d{4}"'
    assert_includes body, 'title="Please match the format 555-555-5555"'
    assert_includes body, 'data-action="keydown-&gt;phone#down input-&gt;phone#input"'
    assert_match %r{placeholder="555-555-5555"[^>]*type="phone"}, body
    assert_match %r{placeholder="michael@example\.com"[^>]*type="email"}, body
  end

  # The plugin builds the hidden input Rails reads from `data-bs-name`, so there
  # is no `name=` on the toggle and no text field for the foreign key at all.
  def test_a_belongs_to_column_becomes_a_combobox_of_names
    session = ActionDispatch::Integration::Session.new Rails.application
    session.get '/admin/markets/new'
    body = session.response.body

    assert_includes body, "data-bs-toggle='combobox' data-bs-name='market[state_id]'"
    assert_includes body, "data-bs-value='#{State.find_by!(code: 'AL').id}' " \
                          "aria-selected='false'>Alabama</button>"
    refute_includes body, 'name="market[state_id]"'
    # The button that empties the menu's search. Hidden until there is something to
    # clear, which only JavaScript can know.
    assert_includes body, "class='combobox-search-clear d-none' aria-label='Clear search'"
    assert_includes body, "data-clear-target='input' data-action='input->clear#toggle'"
  end
end
