require 'test_helper'
require 'action_dispatch/testing/integration'

# Which field a column gets, and the HTML that constrains it.
class TestRecoursesFields < Minitest::Test
  def test_a_required_email_shows_an_example_address
    session = ActionDispatch::Integration::Session.new Rails.application
    session.get '/providers/new'

    assert_match %r{placeholder="michael@example\.com"[^>]*name="provider\[email\]"},
                 session.response.body
  end

  # What a column holds is what its field is. Only the two kinds no column type can
  # tell apart are types the dummy app registers, `:price` and `:percentage`.
  def test_each_kind_of_number_gets_the_field_that_fits_it
    session = ActionDispatch::Integration::Session.new Rails.application
    session.get '/providers/new'
    body = session.response.body

    assert_includes body, '<div><input name="provider[active]" type="hidden" value="0" />' \
                          '<input class="check" type="checkbox"'
    assert_match %r{step="1" type="number" name="provider\[review_number\]"}, body
    assert_match %r{step="any" type="number" name="provider\[service_radius\]"}, body
    # A scale says how many decimals fit, and a precision how many digits in all.
    assert_includes body, 'step="0.01" max="99.99" type="number" value="15.0"'
    # An enum is a menu of the words it admits, and a counter cache is not a field.
    assert_includes body, %(data-bs-value='small')
    refute_includes body, 'provider[bookings_count]'
  end

  # The unit adorns the control rather than sitting inside it: at the end for a
  # percentage, at the start for money, and the input inside is a ghost either way.
  def test_a_price_and_a_percentage_wear_their_unit
    session = ActionDispatch::Integration::Session.new Rails.application
    session.get '/providers/new'
    body = session.response.body

    assert_includes body, '<div class="form-control form-adorn d-flex form-adorn-end">' \
                          '<span class="form-adorn-text">%</span><input class="form-ghost"'
    assert_includes body, '<div class="form-control form-adorn d-flex">' \
                          '<span class="form-adorn-text">$</span><input class="form-ghost"'
  end

  # The host's own `_fields` names both types, which beats the encrypted-column
  # rule, and the phone carries the only bracket class of any pattern in the app.
  def test_a_host_names_the_types_and_the_title_shows_the_format
    session = ActionDispatch::Integration::Session.new Rails.application
    session.get '/contacts/new'
    body = session.response.body

    assert_includes body, 'pattern="[2-9]\d{2}-[2-9]\d{2}-\d{4}"'
    assert_includes body, 'title="Please match the format 555-555-5555"'
    assert_includes body, 'data-action="keydown-&gt;phone#down input-&gt;phone#input"'
    assert_match %r{placeholder="555-555-5555"[^>]*type="phone"}, body
    assert_match %r{placeholder="michael@example\.com"[^>]*type="email"}, body
  end

  # A pattern with neither a canonical sample nor only digits: the title is read off
  # the pattern, a bracket class giving its first character and a literal itself.
  def test_a_pattern_with_no_sample_shows_a_value_that_would_match
    session = ActionDispatch::Integration::Session.new Rails.application
    session.get '/franchises/new'

    assert_includes session.response.body, 'title="Please match the format a-0000"'
  end

  # The plugin builds the hidden input Rails reads from `data-bs-name`, so there
  # is no `name=` on the toggle and no text field for the foreign key at all.
  def test_a_belongs_to_column_becomes_a_combobox_of_names
    session = ActionDispatch::Integration::Session.new Rails.application
    # Its own row to pick, since another test may have cleared the locations table.
    location = Location.create! zip: ZIP.first!, city: 'Comboboxville'
    session.get '/jobs/new'
    body = session.response.body

    assert_includes body, "data-bs-toggle='combobox' data-bs-name='job[location_id]'"
    assert_includes body, "data-bs-value='#{location.id}' aria-selected='false'>" \
                          "<span class='menu-item-content'><span>Comboboxville</span></span>"
    refute_includes body, 'name="job[location_id]"'
  ensure
    location&.destroy
  end

  # The button that empties the menu's search. Hidden until there is something to
  # clear, which only JavaScript can know.
  def test_a_combobox_search_carries_a_button_that_empties_it
    session = ActionDispatch::Integration::Session.new Rails.application
    session.get '/jobs/new'
    body = session.response.body

    assert_includes body, "class='combobox-search-clear d-none' aria-label='Clear search'"
    assert_includes body, "data-clear-target='input' data-action='input->clear#toggle'"
  end
end
