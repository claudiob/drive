require 'test_helper'
require 'action_dispatch/testing/integration'

# How the index page paginates: 20 rows, a count, and Bootstrap nav links.
class TestRecoursesPagination < Minitest::Test
  def setup
    Contact.delete_all
    25.times { |index| Contact.create! phone: format('55522%05d', index) }
    @session = ActionDispatch::Integration::Session.new Rails.application
  end

  def test_it_puts_twenty_rows_on_a_page
    visit_index

    assert_equal 20, rows
  end

  def test_it_shows_how_many_items_there_are
    visit_index

    assert_includes body, 'Displaying items 1-20 of 25 in total'
  end

  def test_it_links_the_pages_with_bootstrap_markup
    visit_index

    assert_includes body, 'class="pagy-bootstrap series-nav"'
    assert_includes body, '<ul class="pagination'
    assert_includes body, 'href="/contacts?page=2"'
  end

  def test_it_costs_one_count_and_one_select
    queries = contact_queries { visit_index }

    assert_equal 2, queries.size
    assert_equal 1, queries.grep(/COUNT/).size
  end

private

  def visit_index
    @session.get '/contacts'
  end

  def body
    @session.response.body
  end

  def rows
    body.scan('<tr>').size - 1
  end

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
