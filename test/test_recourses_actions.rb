require 'test_helper'
require 'integration_case'

# An action the routes drew under a record with no page of its own to reach it
# from, and the button the gem puts on the record instead.
class TestRecoursesActions < IntegrationCase
  # This suite runs against a database that keeps whatever a test wrote, so what
  # these tests write they also take back.
  def teardown
    Memo.where(body: 'Noted').destroy_all
    Membership.find_or_create_by! person: Person.order(:id).first, team: Team.order(:id).first
  end

  # A nested resource routed `create` with no index is reached from nowhere, so the
  # gem puts its button on the record it hangs off, wherever that record is shown.
  def test_a_nested_action_with_no_page_gets_a_button_on_its_parent
    person = Person.order(:id).first
    visit "/people/#{person.id}/places"

    assert_includes body, %(action="/people/#{person.id}/quick/memos")
    assert_includes body, 'Add memo'
    @session.post "/people/#{person.id}/quick/memos"

    assert_equal 303, @session.response.status
    assert_equal 'Noted', person.memos.order(:id).last.body
  end

  # And the same for one drawn `recourse` rather than `recourses`: a single record
  # reached with no id, whose destroy is an action on the record it hangs off.
  def test_a_singular_nested_action_gets_a_button_too
    place = Place.order(:id).first
    Memo.create! body: 'About this place', about: place
    visit "/places/#{place.id}"

    assert_includes body, %(action="/places/#{place.id}/memo")
    assert_includes body, 'Delete memo'
    @session.delete "/places/#{place.id}/memo"

    assert_equal 303, @session.response.status
    assert_empty Memo.where(about: place)
  end

  # The sidebar lists what the routes declared. An app's own way out of it is not
  # one of those, so the host says it the same way it says a tab.
  def test_a_host_may_add_a_link_the_sidebar_cannot_declare
    visit '/people'

    assert_includes body, %(action="/session")
    assert_includes body, 'Sign out'
  end

  # A listing of the far side of a many-to-many: every team rather than the ones this
  # person is on, with the membership to add or drop beside each. The path names both
  # records, so the button submits nothing and the join earns no page of its own.
  def test_a_listing_may_edit_the_join_beside_each_row
    person = Person.order(:id).first
    joined = person.teams.order(:id).first
    visit "/people/#{person.id}/teams"

    assert_equal Team.count, body.scan('data-cell="Name"').size
    assert_equal person.teams.count, body.scan('>Remove<').size
    assert_includes body, %(action="/people/#{person.id}/teams/#{joined.id}/membership")

    @session.delete "/people/#{person.id}/teams/#{joined.id}/membership"

    assert_equal 303, @session.response.status
    refute_includes person.reload.teams, joined

    @session.post "/people/#{person.id}/teams/#{joined.id}/membership"

    assert_equal 303, @session.response.status
    assert_includes person.reload.teams, joined
  end
end
