require 'test_helper'
require 'action_dispatch/testing/integration'

# The index a `recourses` block nests under a parent resource.
class TestRecoursesNesting < Minitest::Test
  # A nested index lists the parent record's own rows and nothing else: no column
  # repeats the parent, the breadcrumb walks down through the record, and the
  # sidebar marks the parent's entry, which is how the page was reached.
  def test_it_serves_an_index_nested_under_a_record
    county = County.first
    session = ActionDispatch::Integration::Session.new Rails.application
    session.get "/counties/#{county.id}/zips"
    body = session.response.body

    assert_includes body, "Displaying #{county.zips_count} items"
    refute_includes body, 'data-cell="County"'
    assert_includes body, '<a class="breadcrumb-link gap-2" href="/counties">'
    assert_includes body, "<span class='breadcrumb-link'>#{county.name}</span>"
    assert_includes body, 'aria-current="page" data-key="c" href="/counties">'
  end
end
