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
    market = Market.create! name: 'Chicago Metro'
    ZIP.first!.update! market: market
    @session.get '/zips'
    body = @session.response.body

    assert_includes body, 'name="q[code_or_county_name_cont]"'
    assert_includes body, "data-bs-name='q[market_id_in]'"
    assert_includes body, "Chicago Metro<span class='recourse-count fg-2'>1</span>"
    refute_includes body, 'q[county_id_in]'
  ensure
    ZIP.first!.update! market: nil
    market&.destroy
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
