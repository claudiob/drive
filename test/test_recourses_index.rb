require 'test_helper'
require 'action_dispatch/testing/integration'

# The page `recourses` renders for a resource that belongs to another.
class TestRecoursesIndex < Minitest::Test
  def test_it_serves_a_resource_that_belongs_to_another
    session = ActionDispatch::Integration::Session.new Rails.application
    session.get '/counties'

    assert_equal 200, session.response.status
    assert_includes session.response.body, '<th scope="col">State</th>'
    assert_includes session.response.body, 'data-cell="Fips"'
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

    assert_includes session.response.body, %(<td data-cell="Media urls">#{urls.join ', '}</td>)
  ensure
    message&.destroy
    contact&.destroy
  end
end
