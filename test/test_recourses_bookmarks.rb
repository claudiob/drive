require 'test_helper'
require 'integration_case'

# The square a table opens with, and the two writes behind it.
class TestRecoursesBookmarks < IntegrationCase
  KEPT = 4

  def teardown
    Bookmark.where.not(topic_id: [KEPT, 7]).destroy_all
    Bookmark.find_or_create_by! person: Person.order(:id).first, topic: Place.find(KEPT)
  end

  # One pass over a table that has both: the kept row filled and asking to be
  # dropped, the unkept one hollow and asking to be kept, both at the same path with
  # only the verb between them — and the kept rows leading, which is the order a
  # model's own `recourse_order` gives way to.
  def test_the_column_draws_both_states_and_leads_with_what_is_kept
    visit '/places'

    assert_includes body, '<i class="bi bi-bookmark-fill" aria-label="Remove bookmark">'
    assert_includes body, '<i class="bi bi-bookmark" aria-label="Bookmark">'
    assert_includes body, '<input type="hidden" name="_method" value="delete" />'
    assert_includes body, %(action="/places/#{KEPT}/bookmark")
    assert_equal %w[4 7 1], body.scan(%r{/places/(\d+)/edit}).flatten.first(3)
  end

  # What the Stimulus controller reads off the button, asserted from here because a
  # typo in one of these fails silently in a browser and nowhere else.
  def test_the_square_carries_what_the_browser_needs_to_flip_it
    visit '/places'

    assert_includes body, 'data-controller="bookmark tooltip"'
    assert_includes body, 'aria-pressed="true"'
    assert_includes body, 'data-bookmark-error-value="Bookmark could not be saved."'
  end

  # A model that declares no bookmarks has not opted in, so its table opens where it
  # always did rather than on a column nobody can fill.
  def test_a_model_that_keeps_none_gets_no_column
    visit '/teams'

    refute_includes body, 'bi-bookmark'
    refute_includes body, 'data-cell="Bookmark"'
  end

  # The viewer comes from the host's own declaration rather than from the form, so
  # `create` writes a row nobody submitted a person for.
  def test_create_keeps_the_row_for_whoever_is_looking_and_says_so
    @session.post '/places/1/bookmark'

    assert_equal 303, @session.response.status
    bookmark = Bookmark.find_by! topic: Place.find(1)

    assert_equal Person.order(:id).first, bookmark.person
    follow_and_assert_flash 'Bookmark added.'
  end

  def test_destroy_drops_it_and_warns
    @session.delete "/places/#{KEPT}/bookmark"

    assert_equal 303, @session.response.status
    assert_empty Bookmark.where(topic: Place.find(KEPT))
    follow_and_assert_flash 'Bookmark removed.'
  end

  # The background request the square actually makes: nothing to render, and — the
  # point of the branch — no flash left in the session to surface as a toast on
  # whatever page is loaded next.
  def test_a_background_request_is_answered_with_nothing_at_all
    @session.post '/places/1/bookmark', headers: { 'ACCEPT' => 'application/json' }

    assert_equal 204, @session.response.status
    assert_empty @session.response.body
    visit '/places'
    refute_includes body, 'Bookmark added.'
  end

  # Twice kept is once kept: the square answers before the request does, so a second
  # click can arrive while the first is still in flight.
  def test_keeping_a_row_twice_keeps_it_once
    2.times { @session.post '/places/1/bookmark' }

    assert_equal 1, Bookmark.where(topic: Place.find(1)).count
  end

  # No square is drawn for a model that keeps none, so the only way here is by hand.
  def test_a_resource_that_keeps_none_is_not_there
    assert_raises(ActiveRecord::RecordNotFound) { @session.post '/teams/1/bookmark' }
  end

private

  def follow_and_assert_flash(message)
    @session.follow_redirect!

    assert_includes body, message
  end
end
