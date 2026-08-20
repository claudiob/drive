require_relative 'integration_case'

# What a model says by marking one key of `recourse_order` `:positionable`, and what
# the table it draws stops offering once it has.
class TestRecoursesPositions < IntegrationCase
  def test_a_marked_key_names_the_column_a_table_is_arranged_by
    assert_equal 'position', Recourse.position_column(Team)
  end

  def test_a_model_that_marks_nothing_is_arranged_by_nothing
    assert_nil Recourse.position_column(Place)
  end

  # The word means ascending to Active Record, which has never heard of it, and the
  # hash a host wrote is left as it wrote it.
  def test_the_marked_key_reaches_active_record_as_ascending
    assert_equal({ position: :asc }, Recourse.order_for(Team))
    assert_equal({ position: :positionable }, Team.recourse_order)
  end

  def test_an_order_that_is_not_a_hash_is_passed_straight_through
    assert_equal :id, Recourse.order_for(Place)
  end

  def test_it_refuses_a_column_the_table_has_not_got
    error = assert_raises Recourse::Error do
      arranged_by(:nowhere) { Recourse.position_column Team }
    end

    assert_includes error.message, 'no such column'
  end

  # A column no index covers is one no table can be read in the order of, which is
  # the whole of what arranging asks for.
  def test_it_refuses_a_column_no_index_covers
    error = assert_raises Recourse::Error do
      arranged_by(:uid) { Recourse.position_column Team }
    end

    assert_includes error.message, 'no database index covers it'
  end

  def test_it_refuses_two_orders_for_one_table
    error = assert_raises Recourse::Error do
      arranged_by(:position, :uid) { Recourse.position_column Team }
    end

    assert_includes error.message, 'two orders for one table'
  end

  # The headings of an arranged table are words rather than links, and no form sits
  # above it: both would read its rows in an order nobody set.
  def test_an_arranged_table_offers_no_heading_to_sort_by_and_no_box_to_search_with
    visit '/teams'

    assert_includes body, '<th scope="col">Name</th>'
    refute_includes body, 'q%5Bs%5D'
    refute_includes body, 'role="search"'
  end

  # And the refusal is the query's rather than the page's, so a sort typed into the
  # address bar is answered in the order the reader set anyway.
  def test_a_sort_asked_for_by_url_leaves_an_arranged_table_where_it_was
    visit '/teams?q%5Bs%5D=name+desc'

    assert_operator body.index('Blue Crew'), :<, body.index('Red Shift')
  end

private

  # Marks the named keys `:positionable` on Team for the length of the block, so a
  # declaration the dummy would never ship can still be asked about.
  def arranged_by(*columns)
    order = columns.to_h { |column| [column, :positionable] }
    Team.define_singleton_method(:recourse_order) { order }
    yield
  ensure
    Team.singleton_class.remove_method :recourse_order
  end
end
