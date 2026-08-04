require 'test_helper'
require 'action_dispatch/testing/integration'

# What `recourses :contacts, only: :index` in the dummy app's routes.rb produces.
class TestRecourses < Minitest::Test
  def setup
    Contact.delete_all
    @session = ActionDispatch::Integration::Session.new(Rails.application)
  end

  def test_it_serves_the_index_without_the_host_app_owning_a_controller
    @session.get '/contacts'

    assert_equal 200, @session.response.status
  end

  def test_it_defines_the_controller_the_host_app_lacks
    assert_operator ContactsController, :<, RecoursesController
  end

  def test_it_leaves_a_controller_the_host_app_owns_alone
    @session.get '/echoes'

    assert_equal 'the host app answered', @session.response.body
    refute_operator EchoesController, :<, RecoursesController
  end

  def test_it_forwards_options_to_resources
    actions = contact_routes.map { |route| route.defaults[:action] }

    assert_equal %w[index], actions
  end

  def test_it_leaves_the_paths_unprefixed
    assert_equal '/contacts', Rails.application.routes.url_helpers.contacts_path
  end

private

  def contact_routes
    Rails.application.routes.routes.select do |route|
      route.defaults[:controller] == 'contacts'
    end
  end
end
