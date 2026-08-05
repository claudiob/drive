require 'test_helper'
require 'action_dispatch/testing/integration'

# What a warm cache saves. Exempt from "as few tests as coverage needs" for the
# same reason the pagination test is: the lines run either way.
class TestRecoursesCaching < Minitest::Test
  def setup
    Rails.cache.clear
    @session = ActionDispatch::Integration::Session.new Rails.application
  end

  def test_a_warm_combobox_checks_its_version_without_fetching_the_rows_again
    cold = state_queries { @session.get '/markets/new' }
    warm = state_queries { @session.get '/markets/new' }

    assert_equal 2, cold.size
    assert_match(/COUNT/, warm.sole)
  end

private

  def state_queries
    queries = []
    subscription = ActiveSupport::Notifications.subscribe 'sql.active_record' do |*, payload|
      queries << payload[:sql] if payload[:sql].include? 'FROM "states"'
    end
    yield
    queries
  ensure
    ActiveSupport::Notifications.unsubscribe subscription
  end
end
