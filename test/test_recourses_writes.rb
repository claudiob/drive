require 'test_helper'
require 'integration_case'

# What the four writing actions do, and what each says afterwards.
class TestRecoursesWrites < IntegrationCase
  def teardown
    Place.where(slug: %w[a-new-place kips-place]).destroy_all
    Memo.where(body: ['Memo', 'About Kip']).destroy_all
    Person.where(name: 'Kip').destroy_all
  end

  # A typed reference arrives as the label somebody typed rather than as an id, and
  # `create` looks it up under the foreign key's own name — so no host model needs a
  # virtual attribute and strong parameters need no special case.
  def test_create_looks_up_a_typed_reference_and_returns_to_the_index
    @session.post '/places', params: { place: new_place_params }

    assert_equal 303, @session.response.status
    assert_equal '/places', URI.parse(@session.response.headers['Location']).path
    place = Place.find_by! slug: 'a-new-place'

    assert_equal MSA.find_by!(code: 'M0002'), place.msa
    follow_and_assert_flash 'Place was created.'
  end

  # A record that will not save redraws its own form rather than redirecting, with
  # the message beside the field that earned it and Bootstrap's own two classes on
  # the pair — which the host app's `field_error_proc` is what supplies.
  def test_a_rejected_record_redraws_the_form_with_the_message_beside_the_field
    rejected = new_place_params.merge name: '', team_id: '', msa_id: 'ZZZZZ'
    @session.post '/places', params: { place: rejected }

    assert_equal 422, @session.response.status
    assert_includes body, 'is-invalid'
    assert_includes body, '<small class="invalid-feedback"'
    assert_includes body, 'Can&#39;t be blank'
    # Neither a combobox nor a typed reference is a form builder's tag, so
    # `field_error_proc` never sees either: each draws its own message, and both
    # have to say what the builder's fields would have said.
    assert_equal 2, body.scan('Must exist').size
  end

  def test_update_saves_and_says_so
    team = Team.order(:id).first
    @session.patch "/teams/#{team.id}", params: { team: { name: 'Blue Crew' } }

    assert_equal 303, @session.response.status
    follow_and_assert_flash 'Team was updated.'
  end

  # And a rejected change redraws the form the same way `create` does, rather than
  # redirecting to an index that would show the old value as though nothing failed.
  def test_a_rejected_change_redraws_the_form
    team = Team.order(:id).first
    @session.patch "/teams/#{team.id}", params: { team: { name: '' } }

    assert_equal 422, @session.response.status
    assert_includes body, 'is-invalid'
    assert_equal 'Blue Crew', team.reload.name
  end

  # Deleting names what goes with it before it goes, counted one level down: the
  # children that go too, and the ones that are only let go of.
  def test_destroy_warns_by_name_and_count_then_removes_the_row
    person = Person.create! name: 'Kip', email: 'kip@example.com'
    person.memos.create! body: 'About Kip'
    person.places.create! msa: MSA.order(:id).first, team: Team.order(:id).first,
                          name: 'Kips place', slug: 'kips-place', capacity: 4, active: true
    visit "/people/#{person.id}/edit"
    warning = CGI.unescape_html body[/data-turbo-confirm="([^"]*)"/, 1]

    assert_includes warning, 'Delete Kip?'
    # Counted one level down, each side reading as what its `dependent:` does, and
    # each in the number it is: one place, one memo.
    assert_includes warning, '1 place will be deleted with it.'
    assert_includes warning, '1 memo will be kept, without its person.'
    assert_includes warning, 'Anything under those goes too.'
    assert_includes warning, 'This cannot be undone.'
    @session.delete "/people/#{person.id}"

    assert_equal 303, @session.response.status
    refute Person.exists?(person.id)
  end

  # A nested resource routed `create` without `new` offers a one-click Create in the
  # Add link's place: it posts the record whole and comes back to the index holding
  # it. Our word, in the routes file, that a bare memo can stand.
  def test_a_bare_create_posts_the_record_whole_from_the_index
    person = Person.order(:id).first
    visit "/people/#{person.id}/memos"

    assert_includes body, %(action="/people/#{person.id}/memos")
    assert_includes body, 'Create'
    refute_includes body, %(href="/people/#{person.id}/memos/new")
    @session.post "/people/#{person.id}/memos", params: { memo: { body: 'Memo' } }

    assert_equal 303, @session.response.status
    assert_equal person, Memo.find_by!(body: 'Memo').person
  end

private

  def new_place_params
    { msa_id: 'M0002', team_id: Team.order(:id).first.id, name: 'A new place',
      slug: 'a-new-place', capacity: 10, status: 'draft', active: '1', }
  end

  def follow_and_assert_flash(message)
    @session.follow_redirect!

    assert_includes body, message
  end
end
