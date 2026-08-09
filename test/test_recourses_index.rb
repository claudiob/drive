require 'test_helper'
require 'action_dispatch/testing/integration'

# The page `recourses` renders for a resource that belongs to another.
class TestRecoursesIndex < Minitest::Test
  # A heading sorts by its column, and only the heading: a `data-cell` carries the same
  # title as text, so a narrow screen labels the cell with a word and not a link. The
  # foreign key's heading sorts by nothing, and no column shows the id.
  def test_it_serves_a_resource_that_belongs_to_another
    session = ActionDispatch::Integration::Session.new Rails.application
    session.get '/counties'
    body = session.response.body

    assert_equal 200, session.response.status
    assert_includes body, 'href="/counties?q%5Bs%5D=fips+asc">Fips</a></th>'
    assert_includes body, '<th scope="col">State</th>'
    assert_includes body, '<td data-cell="State">Alabama</td>'
    refute_includes body, 'data-cell="Id"'
    # Census data, written once: the model says so, and the two columns go with it.
    refute_includes body, 'data-cell="Created at"'
  end

  # A sidebar link answers to a letter of its own title, and the first one free: both
  # of these start with C, and Counties is declared first.
  def test_each_sidebar_entry_marks_the_letter_that_reaches_it
    session = ActionDispatch::Integration::Session.new Rails.application
    session.get '/counties'
    body = session.response.body

    assert_includes body, '<span class="recourse-key">C</span>ounties'
    assert_includes body, 'Co<span class="recourse-key">n</span>tacts'
    # A namespaced resource is its own entry, linking where its routes were drawn.
    assert_includes body, 'href="/admin/sources"'
    # And the icon beside each is the concept its model names, not a title looked up
    # in a list: nothing anywhere says the word `Jobs` draws a hammer.
    assert_includes body, '<i class="bi bi-hammer"></i>'
  end

  # An array column reads as its values, not as the inspect output of an Array. Brings
  # its own contact and takes both rows away again: a message outliving this test would
  # break every other one that clears the contacts it points at.
  def test_it_lists_the_values_of_an_array_column
    urls = %w[https://example.com/a.jpg https://example.com/b.png]
    contact = Contact.create! phone: '5559990001'
    message = Message.create! contact:, inbound: true, media_urls: urls
    session = ActionDispatch::Integration::Session.new Rails.application
    session.get '/messages'

    assert_includes session.response.body, %(<td data-cell="Media URLs">#{urls.join ', '}</td>)
  ensure
    message&.destroy
    contact&.destroy
  end
end
