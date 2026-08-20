require 'test_helper'
require 'integration_case'

# What a page draws once its rows are ones a reader arranges, and what it stops
# drawing: a second way to read them would put them in an order nobody set.
class TestRecoursesArrangements < IntegrationCase
  # The same table, twice, at the two levels: the person's own memos are arranged
  # and offer no box, and every person's memos at once are searched like anything
  # else.
  def test_a_page_above_the_level_keeps_the_search_the_arranged_one_drops
    visit '/people/1/memos'
    refute_includes body, 'role="search"'

    visit '/memos'
    assert_includes body, 'role="search"'
  end

  # A page a host drew over an aggregate names a parent no key links to its rows — a
  # team's memos are the memos of the people whose places it keeps, gathered from
  # several — so they are no more in one order than the whole table is.
  def test_a_page_drawn_over_an_aggregate_arranges_nothing
    visit '/teams/3/memos'

    refute_includes body, 'data-controller="sortable"'
    assert_includes body, 'role="search"'
  end

  # The headings are words rather than links, no form sits above them, and the
  # column the rows are arranged by is not drawn at all — the handles beside each
  # row already say the table is ordered.
  def test_an_arranged_table_offers_no_heading_no_box_and_no_column_of_its_own
    visit '/teams'

    assert_includes body, '<th scope="col">Name</th>'
    refute_includes body, 'q%5Bs%5D'
    refute_includes body, 'role="search"'
    refute_includes body, '>Position<'
  end

  # And the refusal is the query's rather than the page's, so a sort typed into the
  # address bar is answered in the order the reader set anyway.
  def test_a_sort_asked_for_by_url_leaves_an_arranged_table_where_it_was
    visit '/teams?q%5Bs%5D=name+desc'

    assert_operator body.index('Blue Crew'), :<, body.index('Red Shift')
  end
end
