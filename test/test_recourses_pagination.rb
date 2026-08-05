require 'test_helper'
require 'action_dispatch/testing/integration'

# What an index page costs in queries, which coverage cannot see for itself.
class TestRecoursesPagination < Minitest::Test
  def setup
    Contact.delete_all
    25.times { |index| Contact.create! phone: format('55522%05d', index) }
    @session = ActionDispatch::Integration::Session.new Rails.application
  end

  def test_it_costs_one_count_and_one_select
    queries = contact_queries { @session.get '/contacts' }

    assert_equal 2, queries.size
    assert_equal 1, queries.grep(/COUNT/).size
  end

private

  def contact_queries
    queries = []
    subscription = ActiveSupport::Notifications.subscribe 'sql.active_record' do |*, payload|
      queries << payload[:sql] if payload[:sql].include? 'FROM "contacts"'
    end
    yield
    queries
  ensure
    ActiveSupport::Notifications.unsubscribe subscription
  end
end
