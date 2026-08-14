require 'test_helper'
require 'action_dispatch/testing/integration'

# Sorting a table by one of its headings, and narrowing it with the form above it.
class TestRecoursesSearch < Minitest::Test
  def setup
    @session = ActionDispatch::Integration::Session.new Rails.application
  end

  # Following a heading's own link: the order it asks for replaces the model's, and
  # the heading says which way it went.
  def test_a_heading_sorts_the_table_by_its_column
    @session.get '/counties?q%5Bs%5D=name+desc'
    body = @session.response.body

    assert_includes body, "<td data-cell=\"Name\">#{County.maximum :name}</td>"
    assert_includes body, 'bi bi-caret-down-fill'
    # The table and its pagination are what a search or a sort replaces, so both sit
    # inside the frame the form targets, and the edit link inside it breaks back out.
    assert_includes body, "<turbo-frame id='results' data-turbo-action='advance'>"
    assert_includes body, 'data-turbo-frame="results"'
  end

  # Two values in one filter, which is how a multiple combobox submits them, beside a
  # search box left empty — `IN ()` would match no row rather than every one.
  def test_a_filter_of_two_values_narrows_the_table_and_marks_its_menu
    states = State.where(code: %w[AK AL]).order :code
    @session.get "/counties?q%5Bstate_id_in%5D=#{states.ids.join ','}&q%5Bfips_cont%5D="
    body = @session.response.body

    assert_includes body, "data-bs-value='#{states.first.id}' aria-selected='true'"
    # The way back to no filter at all. It carries no `data-bs-value`, which is what
    # keeps Bootstrap's own click handler off it, and never `.selected`, which it counts.
    assert_includes body, "data-action='deselect#all'>All states</button>"
    assert_includes body, "of #{County.where(state: states).count} in total"
  end

  # What matched is marked, and only in the column that matched it: the state beside
  # it is not searched, so the word `Alabama` is never marked by a search for one.
  def test_a_search_marks_what_it_matched
    @session.get '/counties?q%5Bname_cont%5D=Autauga'
    body = @session.response.body

    assert_includes body, '<td data-cell="Name"><mark>Autauga</mark> County</td>'
    assert_includes body, '<td data-cell="State">Alabama</td>'
  end

  # 3,144 counties are too many for a menu, so the ZIPs page searches their names
  # instead of listing them, and the market it can list keeps its own filter. Each
  # market in that menu says how many of the rows being filtered are its own, since
  # a market is one of the models that counts its ZIPs.
  def test_a_long_table_is_searched_rather_than_listed
    markets = counted_markets
    @session.get '/zips'
    body = @session.response.body

    assert_includes body, 'name="q[code_or_county_name_cont]"'
    assert_includes body, "data-bs-name='q[market_id_in]'"
    assert_includes body, "Alpha Market<span class='recourse-count fg-2'>1</span>"
    refute_includes body, 'q[county_id_in]'
  ensure
    clear_markets markets
  end

  # Read from the top, so the option most of the rows are behind is the first offered:
  # `Zebra` outranks `Alpha` on two ZIPs against one, which alphabetical order would
  # have had the other way round.
  def test_a_counted_filter_offers_its_commonest_option_first
    markets = counted_markets
    @session.get '/zips'
    body = @session.response.body

    assert_operator body.index('Zebra Market'), :<, body.index('Alpha Market')
  ensure
    clear_markets markets
  end

  # A market with none of the rows being filtered is in the menu without being on it —
  # `d-none` until `All` asks for it — and one already ticked is on it either way, or
  # the box would name a filter its own menu does not offer.
  def test_a_filter_keeps_an_option_with_nothing_behind_it_hidden
    empty = Market.create! name: 'Empty Market'
    @session.get '/zips'

    assert_includes @session.response.body,
                    "class='menu-item d-none' type='button' data-bs-value='#{empty.id}'"

    @session.get "/zips?q%5Bmarket_id_in%5D=#{empty.id}"

    assert_includes @session.response.body,
                    "class='menu-item selected' type='button' data-bs-value='#{empty.id}'"
  ensure
    empty&.destroy
  end

  # One ZIP for `Alpha` and two for `Zebra`, so the count and the alphabet disagree
  # about which of them comes first.
  def counted_markets
    alpha, zebra = %w[Alpha Zebra].map { |name| Market.create! name: "#{name} Market" }
    ZIP.limit(3).each_with_index { |zip, index| zip.update! market: index.zero? ? alpha : zebra }

    [alpha, zebra]
  end

  def clear_markets(markets)
    ZIP.where(market: Array(markets).compact).find_each { |zip| zip.update! market: nil }
    Array(markets).each { |one| one&.destroy }
  end

  # A foreign key whose label is typed is offered no filter of its own: that menu
  # would be all 40,965 ZIPs, which is the judgement a form makes too. The search
  # box reaches through to the label instead, so the ZIP is still narrowed by.
  def test_a_typed_reference_is_searched_rather_than_filtered
    @session.get '/locations'
    body = @session.response.body

    assert_includes body, "data-bs-name='q[source_id_in]'"
    refute_includes body, 'q[zip_id_in]'
    assert_includes body, 'name="q[zip_code_cont]"'
    assert_includes body, 'placeholder="Filter by ZIP code"'
    # Nor sortable: the cell holds a code, and `zip_id` is not the order it reads in.
    assert_includes body, '<th scope="col">ZIP code</th>'
  end
end
