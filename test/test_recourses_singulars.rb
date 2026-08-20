require 'test_helper'
require 'integration_case'

# One record nested under another, drawn with `recourse` rather than `recourses`, and
# reached with no id of its own. Rails draws no index for such a resource, so the tab
# on the record it hangs off is the only thing that could lead to it.
class TestRecoursesSingulars < IntegrationCase
  # Routed `show`, a singular resource is a page: named in the singular, since there
  # is only ever one, and taking its turn among the plural tabs in routes.rb order.
  def test_a_singular_nested_show_gets_a_tab_on_its_parent
    place = Place.order(:id).first
    visit "/places/#{place.id}"

    assert_includes body, %(href="/places/#{place.id}/zip">ZIP</a>)
    # A page rather than an action, so nothing posts to it.
    refute_includes body, %(action="/places/#{place.id}/zip")
    assert_operator body.index(%(href="/places/#{place.id}/zip")), :<,
                    body.index(%(href="/places/#{place.id}/photos"))
  end

  # And the page is the place's own, card and all: this tab is the current one, the
  # place's Show and Edit tabs stand beside it unmarked, and the crumbs read back
  # through the record the path named above this one.
  def test_a_singular_nested_show_sits_in_its_parents_card
    place = Place.order(:id).first
    visit "/places/#{place.id}/zip"

    assert_includes body, %(active" aria-current="page" href="/places/#{place.id}/zip")
    assert_includes body, %(href="/places/#{place.id}/edit")
    assert_includes body, place.zip.code
  end

  # Routed anything but a page, it is an action: the button says so and no tab claims
  # a page that is not there.
  def test_a_singular_nested_action_earns_no_tab
    place = Place.order(:id).first
    visit "/places/#{place.id}"

    refute_includes body, %(href="/places/#{place.id}/memo")
    refute_includes body, %(href="/places/#{place.id}/sweep")
    # The button is still there, which is the whole difference between the two.
    assert_includes body, %(action="/places/#{place.id}/memo")
  end
end
