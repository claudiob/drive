require 'test_helper'
require 'action_dispatch/testing/integration'

# The page `recourses` renders for a resource that belongs to another.
class TestRecoursesIndex < Minitest::Test
  # A heading sorts by its column, and only the heading: a `data-cell` carries the same
  # title as text, so a narrow screen labels the cell with a word and not a link. The
  # foreign key's heading sorts by nothing, and no column shows the id.
  def test_it_serves_a_resource_that_belongs_to_another
    body = body_of '/counties'

    assert_includes body, 'href="/counties?q%5Bs%5D=name+asc">Name</a></th>'
    assert_includes body, '<th scope="col">State</th>'
    assert_includes body, '<td data-cell="State">Alabama</td>'
    refute_includes body, 'data-cell="Id"'
    # Census data, written once: the model says so, and the two columns go with it.
    refute_includes body, 'data-cell="Created at"'
    # A counter is headed with the icon of what it counts, named for a reader
    # who cannot see it, and sorts; its cells carry the bare figure.
    icon = '<i class="bi bi-geo-alt" aria-label="ZIPs" role="img" ' \
           'data-controller="tooltip" data-bs-placement="top" data-bs-title="ZIPs"></i>'

    assert_includes body, %(q%5Bs%5D=zips_count+asc">#{icon}</a></th>)
    # And its cell links out of the frame, to the index nested under the row.
    assert_includes body, %(<a data-turbo-frame="_top" href="/counties/#{County.first.id}/zips">)
  end

  # A sidebar link answers to a letter of its own title, and the first one free: both
  # of these start with C, and Counties is declared first.
  def test_each_sidebar_entry_marks_the_letter_that_reaches_it
    body = body_of '/counties'

    assert_includes body, '<span class="recourse-key">C</span>ounties'
    assert_includes body, 'Co<span class="recourse-key">n</span>tacts'
    # A namespaced resource is its own entry, linking where its routes were drawn.
    assert_includes body, 'href="/sources"'
    # And the icon beside each is the concept its model names, not a title looked up
    # in a list: nothing anywhere says the word `Jobs` draws a hammer.
    assert_includes body, '<i class="bi bi-hammer"></i>'
  end

private

  def body_of(path)
    session = ActionDispatch::Integration::Session.new Rails.application
    session.get path

    assert_equal 200, session.response.status
    session.response.body
  end
end
