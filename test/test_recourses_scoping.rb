require 'test_helper'
require 'integration_case'

# What a table lists and which of its columns it draws: two defaults the gem picks
# and a host overrules — one on the model, one in a controller of its own.
class TestRecoursesScoping < IntegrationCase
  # The gem files a polymorphic type column with the machinery and keeps it off every
  # table, the way it does ciphertext and the id; and a route the parent has no
  # association for lists the whole model. Each is a default, and the host is what
  # answers for its own screens — `recourse_displayed` on the model, and
  # `recourse_relation` in the one controller this app writes for itself.
  def test_a_host_may_widen_the_columns_and_narrow_the_rows
    team = Team.order(:id).second
    visit "/teams/#{team.id}/memos"

    assert_includes body, 'data-cell="About type"'
    kept = Memo.where(person: Person.where(id: team.places.select(:person_id))).count

    assert_operator Memo.count, :>, kept
    assert_includes body, "of #{kept} in total"
  end

  # A card carries what the routes can name. Anything else — a page filed under
  # another resource, a page a record only sometimes has — is the host's to add,
  # and `recourse_extra_tabs` is where it says so.
  def test_a_host_may_add_a_tab_no_route_names
    person = Person.order(:id).find { |one| one.places.any? }
    visit "/people/#{person.id}/places"

    assert_includes body, %(href="/zips/#{person.places.first.zip_id}/places">Neighbours</a>)
    # And which records get one is the host's to say: a place is not a person.
    visit "/places/#{person.places.first.id}"

    refute_includes body, 'Neighbours'
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
