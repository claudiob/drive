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
    @session.get '/counties?q%5Bs%5D=fips+desc'
    body = @session.response.body

    assert_includes body, "<td data-cell=\"Fips\">#{County.maximum :fips}</td>"
    assert_includes body, 'bi bi-caret-down-fill'
  end

  # Two values in one filter, which is how a multiple combobox submits them, beside a
  # search box left empty — `IN ()` would match no row rather than every one.
  def test_a_filter_of_two_values_narrows_the_table_and_marks_its_menu
    states = State.where(code: %w[AK AL]).order :code
    @session.get "/counties?q%5Bstate_id_in%5D=#{states.ids.join ','}&q%5Bfips_cont%5D="
    body = @session.response.body

    assert_includes body, "data-bs-value='#{states.first.id}' aria-selected='true'"
    assert_includes body, "of #{County.where(state: states).count} in total"
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
  end
end
