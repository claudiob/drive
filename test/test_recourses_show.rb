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

  # What one record reads out as: the grid row and the heading a form would give
  # the column, plain values, a foreign key as what it points at, the encrypted
  # street masked — and the timestamps the form never offers closing the list,
  # since a record's own page is where "when" belongs.
  READOUTS = [
    '<div class="recourse-row pb-2 mb-3 lg:col-6"><div class="form-label">Summary</div>',
    '<div class="form-control-plaintext">Everything booking</div>',
    '<div class="form-control-plaintext">Cupertino</div>',
    '<div class="form-control-plaintext">Ada</div>',
    'data-reveal-plain-value="1 Infinite Loop"',
    '<div class="form-label">Created at</div>',
    '<div class="form-label">Updated at</div>',
  ].freeze

  def test_it_reads_out_one_record_where_its_form_would_have_been
    visit @filled

    READOUTS.each { |readout| assert_includes body, readout }
    # A button rather than a form is the whole difference from the edit page.
    refute_includes body, '<form'
  end

  # `false` is something a record says, so only nothing at all reads as a dash.
  def test_a_column_the_record_says_nothing_for_reads_as_a_dash
    visit @bare

    assert_includes body, '<div class="form-control-plaintext">—</div>'
    # A boolean is the word it is, and the one this record never answered is the
    # same dash every unanswered column reads as.
    assert_includes body, '<div class="form-control-plaintext">true</div>'
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

  # The row's own way in, beside the pencil where a resource has both pages — and, on
  # the same index, the menu that narrows it by the one enum a booking has.
  def test_the_index_links_to_it_and_offers_its_enum_as_a_filter
    @session.get '/bookings'

    assert_includes body, %(aria-label="Show" data-turbo-frame="_top" href="/bookings/#{@bare.id}")
    assert_includes body, '<i class="bi bi-eye"></i>'
    assert_includes body, "data-bs-name='q[status_in]'"
    assert_includes body, "data-bs-value='scheduled'"
    assert_includes body, "data-action='deselect#all'>All statuses</button>"
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
