require 'test_helper'
require 'action_dispatch/testing/integration'

# The filter menus above a table: which references earn one, and what each offers.
class TestRecoursesFilters < Minitest::Test
  def setup
    @session = ActionDispatch::Integration::Session.new Rails.application
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
    assert_includes body, "Alpha Market</span></span><span class='recourse-count fg-2'>1</span>"
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

private

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
end
