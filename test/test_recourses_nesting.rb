require 'test_helper'
require 'action_dispatch/testing/integration'

# The index a `recourses` block nests under a parent resource.
class TestRecoursesNesting < Minitest::Test
  # A nested index lists the parent record's own rows and nothing else: no column
  # repeats the parent, the breadcrumb walks down through the record, and the
  # sidebar marks the parent's entry, which is how the page was reached.
  def test_it_serves_an_index_nested_under_a_record
    county = County.first
    session = ActionDispatch::Integration::Session.new Rails.application
    session.get "/counties/#{county.id}/zips"
    body = session.response.body

    assert_includes body, "Displaying #{county.zips_count} items"
    refute_includes body, 'data-cell="County"'
    assert_includes body, '<a class="breadcrumb-link gap-2" href="/counties">'
    assert_includes body, 'aria-current="page" data-key="c" href="/counties">'
    assert_parent_chrome body, county
  end

  # The search form drops the parent's own filter the way the table drops its
  # column: /sources/1/contacts is filtered by source_id in the URL itself, and a
  # menu for it would only offer to re-ask. Every other filter stands.
  def test_a_nested_index_offers_no_filter_for_the_parent
    source = Source.create! name: 'A source whose name runs far past the forty a crumb holds'
    session = ActionDispatch::Integration::Session.new Rails.application
    session.get "/sources/#{source.id}/contacts"
    body = session.response.body

    assert_includes body, "data-bs-name='q[agent_id_in]'"
    # And the crumb naming the parent stops at forty characters of its label.
    assert_includes body, 'A source whose name runs far past the...'
    ['q[source_id_in]', 'forty a crumb holds'].each { |gone| refute_includes body, gone }
  ensure
    source&.destroy
  end

  # A nested form never asks which parent the record is for — the path answered,
  # and `create` writes the route's county whatever a form is made to submit.
  def test_a_nested_form_does_not_ask_for_the_parent
    county = County.first
    session = ActionDispatch::Integration::Session.new Rails.application
    session.get "/counties/#{county.id}/zips/new"

    assert_includes session.response.body, 'zip[code]'
    refute_includes session.response.body, 'zip[county_id]'
  end

  # Reached through a parent, a nested resource defaults to its collection actions
  # — list the parent's rows, add one — and an explicit `only:` is the host's word.
  # Drawn into a fresh route set, so the dummy's own routes gain nothing.
  def test_a_nested_recourses_defaults_to_its_collection_actions
    routes = ActionDispatch::Routing::RouteSet.new
    routes.draw do
      recourses :jobs, only: [] do
        recourses :messages
        recourses :bookings, only: :show
      end
    end
    actions = actions_by_controller routes

    assert_equal %w[create index new], actions['jobs/messages']
    assert_equal %w[show], actions['jobs/bookings']
  end

  # The namespace only a `recourses` block adds is what every nested page relies on,
  # so nesting inside a plain `resources` block fails while the routes draw rather
  # than answering a broken page later.
  def test_it_refuses_recourses_nested_inside_plain_resources
    error = assert_raises Recourse::Error do
      ActionDispatch::Routing::RouteSet.new.draw do
        resources :counties, only: :index do
          recourses :zips, only: :index
        end
      end
    end

    assert_includes error.message, 'Nest it under `recourses :counties` instead.'
  end

private

  # The page reads as the parent record's: its crumb links to the record's show
  # page, icon-less, and the index sits in the record's card — the parent's own
  # Show tab first, then this page's tab, the count behind the counted model's
  # icon, marked current.
  def assert_parent_chrome(body, county)
    assert_includes body,
                    %(<a class="breadcrumb-link" href="/counties/#{county.id}">#{county.name}</a>)
    assert_includes body, %(href="/counties/#{county.id}"><i class="bi bi-eye"></i> Show</a>)
    assert_includes body, %(#{county.zips_count} ZIPs</a>)
    assert_includes body, %(aria-current="page" href="/counties/#{county.id}/zips">)
  end

  def actions_by_controller(routes)
    routes.routes.group_by { |route| route.defaults[:controller] }
          .transform_values { |drawn| drawn.map { |route| route.defaults[:action] }.sort }
  end
end
