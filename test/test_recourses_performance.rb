require 'test_helper'
require 'integration_case'

# What a page costs. Exempt from "as few tests as coverage needs": the same lines
# run whether a page issues two queries or forty, so no covered line stands in for
# either of these — and a later edit could quietly add one back.
class TestRecoursesPerformance < IntegrationCase
  def setup
    Rails.cache.clear
    # Asked once per class per process, and this counts what a *request* costs.
    # Left to chance it lands in whichever test reaches a Team menu first.
    Team.recourse_listable?
    super
  end

  # One count for the pagination and one select for the rows, however many rows
  # there are and however many belongs_to each names: a table showing a referenced
  # record would otherwise be a query per cell, and the eager load is what stops it.
  def test_an_index_costs_one_count_and_one_select_on_its_own_table
    queries = queries_on('places') { visit '/places' }

    assert_equal 2, queries.size
    assert_match(/COUNT/, queries.first)
    refute_match(/COUNT/, queries.last)
  end

  # The menu behind a combobox is cached on the relation, so a second request reads
  # the rows again only if a row changed — and asks that in one count rather than by
  # fetching them. The count is the price of never serving a stale menu.
  def test_a_warm_combobox_checks_its_version_without_fetching_the_rows_again
    cold = queries_on('teams') { visit '/places/new' }
    warm = queries_on('teams') { visit '/places/new' }

    assert_equal 2, cold.size
    assert_match(/COUNT/, warm.sole)
  end

  # A counter cache bumps the parent's column without touching its `updated_at`, so
  # a table keyed on the relation would serve the cached figure — `touch: true`
  # beside the counter is what expires it.
  def test_a_new_child_expires_the_cached_count_on_the_parents_index
    team = Team.order(:id).first
    visit '/teams'
    # The figure links to wherever the counted rows were nested, which here is under
    # a namespace — read off the routes rather than joined onto the parent's path.
    cell = %r{<td data-cell="Places"[^>]*><a[^>]*href="/teams/#{team.id}/visited/places">(\d+)</a>}
    before = body[cell, 1].to_i
    place = team.places.create! msa: MSA.order(:id).first, name: 'Counted', slug: 'counted',
                                capacity: 1, active: true
    visit '/teams'

    assert_equal before + 1, body[cell, 1].to_i
  ensure
    place&.destroy
  end
end
