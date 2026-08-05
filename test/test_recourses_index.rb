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
end
