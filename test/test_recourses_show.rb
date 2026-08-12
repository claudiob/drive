require 'test_helper'
require 'action_dispatch/testing/integration'

# The page a resource whose `show` route is drawn gets for one of its records.
class TestRecoursesShow < Minitest::Test
  # Created rather than looked up: what a migration backfilled is what another test
  # clears, and a row a test needs is a row it makes.
  def setup
    @session = ActionDispatch::Integration::Session.new Rails.application
    @contact = Contact.create! name: 'Ada', phone: '2125550999'
    @filled = Booking.create! summary: 'Everything booking', contact: @contact,
                              zip: ZIP.first!, city: 'Cupertino', subscribed: false,
                              street: '1 Infinite Loop'
    @bare = Booking.create! summary: 'Bare booking', contact: @contact, zip: ZIP.first!
  end

  def teardown
    [@filled, @bare].each(&:destroy)
    @contact.destroy
  end

  # The heading a form would give the column, the value the table would print, and
  # the grid the form's fields sit in — two columns on a large viewport.
  def test_it_reads_out_one_record_where_its_form_would_have_been
    visit @filled

    assert_equal 200, @session.response.status
    assert_includes body, '<div class="mb-3 lg:col-6"><div class="form-label">Summary</div>'
    assert_includes body, '<div class="form-control-plaintext">Everything booking</div>'
    assert_includes body, '<div class="form-control-plaintext">Cupertino</div>'
    # A foreign key reads as what it points at, the same as in the table.
    assert_includes body, '<div class="form-control-plaintext">Ada</div>'
    # The same columns the form offers, encrypted ones included — masked, and with
    # a button rather than a form, which is the whole difference from the edit page.
    assert_includes body, 'data-reveal-plain-value="1 Infinite Loop"'
    refute_includes body, '<form'
  end

  # `false` is something a record says, so only nothing at all reads as a dash.
  def test_a_column_the_record_says_nothing_for_reads_as_a_dash
    visit @bare

    assert_includes body, '<div class="form-control-plaintext">—</div>'
    # A boolean is a picture either way, and the one a record never answered is a
    # third picture rather than a dash.
    assert_includes body, '<i class="bi bi-check" aria-label="true"></i>'
    assert_includes body, '<i class="bi bi-square" aria-label="—"></i>'
    # An enum is a badge, in the word the column holds.
    assert_includes body, '<span class="badge">draft</span>'
  end

  # Every kind of number, read out as what it is of rather than as what it is stored
  # as. The two the schema cannot tell apart are types the dummy app registers.
  def test_a_number_reads_as_the_kind_of_number_it_is
    @session.get "/providers/#{Provider.find_by!(name: 'Everything Provider').id}"

    assert_includes body, '<div class="form-control-plaintext">$95.00</div>'
    assert_includes body, '<div class="form-control-plaintext">15.00%</div>'
    assert_includes body, '<div class="form-control-plaintext">12.500</div>'
    assert_includes body, '<div class="form-control-plaintext">4.75</div>'
    assert_includes body, '<div class="form-control-plaintext">128</div>'
    # A counter cache is Rails' to keep, so no page reads one out and no form sets it.
    refute_includes body, 'Bookings'
  end

  # The row's own way in, beside the pencil where a resource has both pages.
  def test_the_index_links_to_it
    @session.get '/bookings'

    assert_includes body, %(aria-label="Show" data-turbo-frame="_top" href="/bookings/#{@bare.id}")
    assert_includes body, '<i class="bi bi-eye"></i>'
  end

  # The breadcrumb links back to the index and then names the record, as edit does.
  def test_it_names_the_record_after_a_link_back
    visit @bare

    assert_includes body, 'href="/bookings">'
    assert_includes body, "<span class='breadcrumb-link active'>Bare booking</span>"
  end

private

  def visit(booking)
    @session.get "/bookings/#{booking.id}"
  end

  def body
    @session.response.body
  end
end
