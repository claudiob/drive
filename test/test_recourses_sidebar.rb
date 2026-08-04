require 'test_helper'
require 'action_dispatch/testing/integration'

# The sidebar: one link per recourse that has an index, in declaration order.
class TestRecoursesSidebar < Minitest::Test
  def setup
    @session = ActionDispatch::Integration::Session.new Rails.application
    @session.get '/contacts'
  end

  def test_it_is_a_vertical_list_beside_the_content
    assert_includes body, "<aside class='col-auto bg-1 py-3 px-0'>"
    assert_includes body, "<ul class='nav flex-column'>"
  end

  def test_it_links_the_index_of_every_recourse
    expected = [['/contacts', 'Contacts'], ['/states', 'States'],
                ['/counties', 'Counties'], ['/echoes', 'Echoes']]

    assert_equal expected, links
  end

  # routes.rb declares states before counties, so a sorted sidebar fails here.
  def test_it_follows_the_order_routes_declare_rather_than_a_sort
    titles = links.map(&:last)

    assert_equal %w[Contacts States Counties Echoes], titles
    refute_equal titles.sort, titles
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
    body.scan(/<a class="nav-link" href="([^"]+)">([^<]+)/)
  end
end
