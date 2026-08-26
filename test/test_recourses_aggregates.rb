require 'test_helper'
require 'integration_case'

# A resource with no rows of its own, which a host writes when a page is assembled out
# of other models' records rather than read off a table.
class Rollup
  include Recourse::Aggregate
end

# And one that says what it is called, which is the only thing an aggregate has to.
class Weekly
  include Recourse::Aggregate

  class << self
    def recourse_label = :headline
    def recourse_icon = :message
  end
end

class TestRecoursesAggregates < IntegrationCase
  # Including it is enough: a class with no table can still be titled, which is what
  # every crumb, tab and heading reads a resource's word from.
  def test_an_aggregate_can_be_named
    assert_equal 'Rollup', Rollup.model_name.human
    assert_equal :rollup, Rollup.recourse_icon
    assert_equal :name, Rollup.recourse_label
  end

  # Everything a table answers from its columns and its keys is answered as the nothing
  # an aggregate has, so the gem asks the same questions of both and neither raises.
  def test_an_aggregate_answers_what_a_table_reads_off_its_columns
    assert_empty Rollup.column_names
    assert_empty Rollup.recourse_hidden
    assert_empty Rollup.recourse_displayed
    assert_empty Rollup.recourse_counters
    assert_empty Rollup.recourse_references
    assert_empty Rollup.recourse_reference_types
  end

  # The two a host has reason to say for itself are the two it can.
  def test_an_aggregate_may_say_what_it_is_called_and_drawn_with
    assert_equal :headline, Weekly.recourse_label
    assert_equal :message, Weekly.recourse_icon
  end

  # And such a page is drawn like any other. The rows are the host's — a template of
  # its own, there being no columns to lay a table out from — and everything around
  # them is the gem's: the crumbs, the sidebar, and the paging.
  def test_an_aggregate_index_is_drawn_like_any_other
    weeks = Week.all
    visit '/weeks'

    assert_includes body, weeks.first.to_s
    assert_includes body, "#{weeks.first.memos} memos"
    # The chrome the gem puts round it, which a host writing a template still gets.
    assert_includes body, '<title>Weeks</title>'
    assert_includes body, 'recourse-sidebar'
  end

  # Paging is the one thing left of what an index does to a collection, and it is done:
  # a page holds what every page holds and the next one carries on where it left off,
  # rather than the host being handed all twenty-six rows to cut down itself.
  def test_an_aggregate_index_is_paged_like_any_other
    weeks = Week.all
    assert_operator weeks.size, :>, Recourse::LIMITS.first

    visit '/weeks'
    assert_equal Recourse::LIMITS.first, rows
    assert_includes body, weeks.first.to_s
    refute_includes body, weeks.last.to_s

    visit '/weeks?page=2'
    assert_equal weeks.size - Recourse::LIMITS.first, rows
    assert_includes body, weeks.last.to_s
    refute_includes body, weeks.first.to_s
  end

  # Nothing to search it by and nothing to sort it by, which is what leaves the page
  # without a box above it and without a link in any heading. Against an ordinary index
  # in the same breath, so the absence is read as this page's rather than as a query
  # string the layout never carries anyway.
  def test_an_aggregate_index_offers_no_search_and_no_sort
    visit '/memos'
    assert_includes body, 'q%5B'

    visit '/weeks'

    refute_includes body, 'q%5B'
    refute_includes body, 'name="q['
  end

private

  # How many rows the page drew, the template giving each an item of its own.
  def rows = body.scan("<li class='list-group-item'>").size
end
