require 'test_helper'
require 'integration_case'

# The form above a table: the box, the menus beside it, and what a match earns.
class TestRecoursesSearch < IntegrationCase
  # What the box looks through is decided by the indexes, and it says so while it is
  # empty. A match is marked, and only in a column the search actually read — a mark
  # anywhere else would claim a match that never happened.
  def test_the_box_searches_the_indexed_columns_and_marks_what_it_matched
    visit '/places'

    # Its own two indexed strings, and the label behind the one foreign key the
    # box reaches through rather than lists — an acronym keeping its capitals.
    assert_includes body, 'name="q[name_or_slug_or_zip_code_cont]"'
    assert_includes body, 'placeholder="Filter by name or slug or ZIP code"'
    visit '/places?q%5Bname_or_slug_or_zip_code_cont%5D=Place+01'

    assert_includes body, '<mark>Place 01</mark>'
    # One row matched, so nothing else is on the page to be marked.
    refute_includes body, 'Place 02'
  end

  # A menu per enum and one per foreign key the box does not reach through instead,
  # each submitting a list predicate so more than one may be ticked at once.
  def test_a_filter_narrows_by_an_enum_and_by_a_reference
    visit '/places'

    assert_includes body, "data-bs-name='q[status_in]'"
    assert_includes body, "data-bs-name='q[team_id_in]'"
    # No menu for the ZIP: 101 rows are more than a menu offers, so the box reaches
    # through that key instead and a filter would only ask the same thing twice.
    refute_includes body, "data-bs-name='q[zip_id_in]'"
    visit "/places?q%5Bstatus_in%5D=#{Place.statuses.keys.last}"

    assert_includes body, Place.statuses.keys.last
    refute_includes body, '<span class="badge">draft</span>'
  end

  # A menu counts what each option would narrow to, and an option that would narrow
  # to nothing is in the menu but not on it — until `All …` asks for it, which is
  # also the way back to no filter at all. One already ticked stays put regardless,
  # or the box would name a filter its own menu does not offer.
  def test_a_filter_hides_the_options_that_would_narrow_to_nothing
    empty = Team.order(:id).last
    visit '/places'
    menu = body[/data-bs-name='q\[team_id_in\]'.*?combobox-no-results/m]

    assert_includes menu, "d-none' type='button' data-bs-value='#{empty.id}'"
    assert_includes menu, 'All teams'
    refute_includes menu, "d-none' type='button' data-bs-value='#{Team.order(:id).first.id}'"
    # Ticked, it stays on the menu however few rows are behind it.
    visit "/places?q%5Bteam_id_in%5D=#{empty.id}"
    menu = body[/data-bs-name='q\[team_id_in\]'.*?combobox-no-results/m]

    refute_includes menu, "d-none' type='button' data-bs-value='#{empty.id}'"
  end

  # A heading that sorted the table says which way, with a caret; the others say
  # nothing, because an arrow on every heading says nothing about the order in force.
  def test_the_sorted_heading_wears_the_caret_and_no_other_does
    visit '/places?q%5Bs%5D=name+desc'

    assert_includes body, 'bi bi-caret-down-fill'
    refute_includes body, 'bi bi-caret-up-fill'
    # And a search keeps the order a heading asked for, carried as a hidden field.
    assert_includes body, '<input type="hidden" name="q[s]" id="q_s" value="name desc"'
  end
end
