require 'test_helper'
require 'action_dispatch/testing/integration'

# An icon is a concept a model picks, not a name a list here holds: the form offers
# every concept, and a menu of records draws each one with the concept it chose.
class TestRecoursesIcons < Minitest::Test
  def setup
    @session = ActionDispatch::Integration::Session.new Rails.application
  end

  def test_a_column_named_icon_offers_every_concept_with_the_icon_it_names
    @session.get '/specialties/new'
    body = @session.response.body

    assert_includes body, "data-bs-placeholder='Select an icon…'"
    # Literal markup in the partial, so single quotes; the record rows below come from
    # `tag.i` and carry double ones.
    assert_includes body, "data-bs-value='house'><i class='bi bi-house'></i> House"
    # The distinct icons, not every name `fetch` answers to.
    assert_equal Unicon.icons.size, body.scan("class='menu-item'").size
  end

  def test_a_column_named_icon_draws_the_concept_it_holds
    # One the first page carries, since the table paginates and `Roofing` is not on it.
    Specialty.find_by(name: 'Ants').update! icon: :house

    @session.get '/specialties'
    body = @session.response.body

    assert_includes body, '<i class="bi bi-house"></i> House'
    # One that picked nothing leaves the cell empty rather than falling back.
    assert_includes body, '<td data-cell="Icon"></td>'
  end

  def test_a_menu_of_records_draws_each_with_the_concept_it_picked
    Specialty.find_by(name: 'Roofing').update! icon: :house

    @session.get '/jobs/new'
    body = @session.response.body

    # The one that picked a concept, and the fallback for one that did not.
    assert_includes body, '<i class="bi bi-house"></i> Roofing'
    assert_includes body, '<i class="bi bi-award"></i> Chimney'
  end
end
