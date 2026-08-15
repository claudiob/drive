require 'test_helper'
require 'action_dispatch/testing/integration'

# The navbar of a nested index whose routes say `create` but not `new`: a Create
# button in the Add link's place, posting the record whole — offered only where
# no column but the route's parent is required, which is Location's exact shape.
class TestRecoursesBareCreate < Minitest::Test
  def setup = @session = ActionDispatch::Integration::Session.new(Rails.application)

  def test_the_navbar_offers_create_in_the_add_links_place
    @session.get "/zips/#{ZIP.first!.id}/locations"

    assert_includes body, '>Create</button>'
    refute_includes body, 'Add location'
  end

  def test_the_button_posts_the_record_whole_and_returns_to_the_index
    zip = ZIP.first!
    @session.post "/zips/#{zip.id}/locations"
    @location = zip.locations.order(:id).last
    @session.follow_redirect!

    assert_equal "/zips/#{zip.id}/locations", @session.request.path
    assert_includes body, 'Location was created.'
  ensure
    @location&.destroy
  end

private

  def body
    @session.response.body
  end
end
