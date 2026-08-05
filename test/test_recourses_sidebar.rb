require 'test_helper'
require 'action_dispatch/testing/integration'

# The sidebar: one link per recourse that has an index, in declaration order.
class TestRecoursesSidebar < Minitest::Test
  def setup
    @session = ActionDispatch::Integration::Session.new Rails.application
    @session.get '/contacts'
  end

  def test_it_is_a_vertical_list_beside_the_content
    assert_includes body, "<aside class='col-auto"
    assert_includes body, "<ul class='nav flex-column'>"
  end

  def test_the_link_to_the_current_page_is_the_active_one
    assert_includes body, '<a class="nav-link active" aria-current="page" href="/contacts">'
    assert_equal 1, body.scan('nav-link active').size
  end

  def test_which_link_is_active_follows_the_page
    @session.get '/states'

    assert_includes body, '<a class="nav-link active" aria-current="page" href="/states">'
    assert_includes body, '<a class="nav-link" href="/contacts">'
  end

  def test_it_links_the_index_of_every_recourse
    expected = [['/contacts', 'Contacts'], ['/states', 'States'],
                ['/counties', 'Counties'], ['/echoes', 'Echoes'],
                ['/markets', 'Markets'], ['/zips', 'ZIPs'],
                ['/sources', 'Sources']]

    assert_equal expected, links
  end

  # routes.rb declares states before counties, so a sorted sidebar fails here.
  def test_it_follows_the_order_routes_declare_rather_than_a_sort
    titles = links.map(&:last)

    assert_equal %w[Contacts States Counties Echoes Markets ZIPs Sources], titles
    refute_equal titles.sort, titles
  end

  def test_every_link_is_preceded_by_an_icon
    icons = {
      'contacts' => 'person-rolodex', 'states' => 'geo', 'counties' => 'map',
      'echoes' => 'soundwave', 'markets' => 'pin-map', 'zips' => 'geo-alt-fill',
      'sources' => 'signpost',
    }

    icons.each do |resource, icon|
      assert_includes body, %(href="/#{resource}"><i class="bi bi-#{icon}"></i>)
    end
  end

  def test_it_skips_a_recourse_that_has_no_index_action
    assert_includes Recourse.declared, 'placeholders'
    refute_includes links.flatten, '/placeholders'
  end

private

  def body
    @session.response.body
  end

  def links
    body.scan %r{<a class="nav-link[^"]*"[^>]*href="([^"]+)"><i[^>]*></i> ([^<]+)}
  end
end
