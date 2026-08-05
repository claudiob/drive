require 'test_helper'
require 'action_dispatch/testing/integration'

# The navbar at the top of every page: a breadcrumb, then room for actions.
class TestRecoursesNavbar < Minitest::Test
  def setup
    Contact.delete_all
    @session = ActionDispatch::Integration::Session.new Rails.application
  end

  def test_every_page_opens_with_a_navbar
    visit '/contacts'

    assert_includes body, "<nav class='navbar"
  end

  def test_the_breadcrumb_names_the_current_page_without_linking_it
    visit '/contacts'

    assert_includes body, "<span class='breadcrumb-link active'>Contacts</span>"
    assert_includes body, "aria-current='page'"
  end

  def test_an_index_breadcrumb_is_a_single_item_with_no_divider
    visit '/contacts'

    assert_equal 1, body.scan("class='breadcrumb-item'").size
    refute_includes body, 'breadcrumb-divider'
  end

  def test_a_new_page_links_back_to_the_index_then_names_itself
    visit '/counties/new'

    assert_includes body, 'class="breadcrumb-link gap-2" href="/counties"'
    assert_includes body, "<span class='breadcrumb-link active'>New county</span>"
    assert_includes body, "<li class='breadcrumb-divider'></li>"
  end

  def test_a_linked_breadcrumb_item_carries_the_resource_icon
    visit '/counties/new'

    assert_includes body, 'href="/counties"><i class="bi bi-map"></i> Counties</a>'
  end

  # Both links are flex, but only .nav-link ships a gap, so the breadcrumb needs
  # gap-2 to put its text the same distance from its icon.
  def test_a_breadcrumb_link_spaces_its_icon_like_the_sidebar_does
    visit '/counties/new'

    assert_includes body, 'class="breadcrumb-link gap-2"'
    assert_includes body, '<a class="nav-link" href="/states">'
  end

  # /counties is routed with :new and its controller implements it.
  def test_it_offers_a_new_link_when_the_resource_has_one
    visit '/counties'

    assert_includes body, 'class="btn theme-primary btn-sm btn-outline ms-3"'
    assert_includes body, 'href="/counties/new">Add county</a>'
  end

  # /contacts is routed `only: :index`, so there is nothing to link to.
  def test_it_offers_no_new_link_when_the_resource_has_none
    visit '/contacts'

    refute_includes body, 'Add contact'
    refute_includes body, 'btn theme-primary'
  end

private

  def visit(path)
    @session.get path
  end

  def body
    @session.response.body
  end
end
