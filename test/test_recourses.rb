require 'test_helper'
require 'action_dispatch/testing/integration'

# What `recourses :contacts` in the dummy app's config/routes.rb draws.
class TestRecourses < Minitest::Test
  def setup
    @session = ActionDispatch::Integration::Session.new(Rails.application)
  end

  # The distinction that matters: a RoutingError would mean no route was drawn,
  # while a NameError means the route is drawn and dispatching, and only the
  # controller behind it is missing.
  def test_visiting_the_index_reaches_a_controller_that_does_not_exist_yet
    error = assert_raises NameError do
      @session.get '/contacts'
    end

    assert_equal 'uninitialized constant Administered::ContactsController', error.message
    refute_kind_of ActionController::RoutingError, error
  end

  def test_the_index_route_points_at_the_namespaced_controller
    index = contact_routes.find { |route| route.defaults[:action] == 'index' }

    assert_equal 'administered/contacts', index.defaults[:controller]
  end

  def test_it_draws_the_same_seven_actions_as_resources
    actions = contact_routes.map { |route| route.defaults[:action] }.uniq

    assert_equal %w[create destroy edit index new show update], actions.sort
  end

  def test_it_leaves_the_paths_unprefixed
    helpers = Rails.application.routes.url_helpers

    assert_equal '/contacts', helpers.contacts_path
    assert_equal '/contacts/1/edit', helpers.edit_contact_path(1)
  end

  private

  def contact_routes
    Rails.application.routes.routes.select do |route|
      route.defaults[:controller] == 'administered/contacts'
    end
  end
end
