require 'test_helper'
require 'action_dispatch/testing/integration'

# The breadcrumb on a page that is not a recourse at all.
class TestRecoursesBreadcrumb < Minitest::Test
  # `/sign_in` is a plain controller with no index, so there is nothing to link back
  # to. It names itself once, unlinked, from the title the page set.
  def test_a_controller_with_no_index_names_itself_and_stops
    session = ActionDispatch::Integration::Session.new Rails.application
    session.get '/sign_in', params: { error: 'access_denied' }
    body = session.response.body

    assert_includes body, "<span class='breadcrumb-link active'>Signing in</span>"
    assert_equal 1, body.scan('breadcrumb-item').size
    refute_includes body, 'breadcrumb-divider'
  end
end
