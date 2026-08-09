require 'test_helper'
require 'action_dispatch/testing/integration'

# What `create` does with a record that saves and with one that does not.
class TestRecoursesCreate < Minitest::Test
  def setup
    @session = ActionDispatch::Integration::Session.new Rails.application
  end

  def test_it_saves_and_returns_to_the_index_with_a_notice
    clear_contacts
    @session.post '/contacts', params: { contact: { phone: '5552234567', name: 'Ada' } }

    assert_equal 303, @session.response.status
    assert_includes @session.response.headers['Location'], '/contacts'
    assert_equal 'Contact was created.', @session.request.flash[:notice]
    assert_equal 'Ada', Contact.sole.name
  end

  # A missing state fails `belongs_to`, which reports on :state, not :state_id, so
  # the message reaches the combobox only because both names are asked.
  def test_it_redraws_the_form_with_the_errors_beside_the_fields
    @session.post '/jobs', params: { job: { title: '' } }

    assert_equal 422, @session.response.status
    assert_includes body, "<div class='toast theme-danger' role='alert'"
    assert_includes body, "<span class='me-auto'>Job could not be created.</span>"
    assert_includes body, "class='form-control is-invalid combobox-toggle'"
    assert_includes body, "<small class='invalid-feedback' id='job_location_id_error'>Must exist"
    assert_includes body,
                    '<input aria-describedby="job_title_error" class="is-invalid form-control"'
    assert_includes body,
                    '<small class="invalid-feedback" id="job_title_error">Can&#39;t be blank'
  end

  # A ZIP is typed rather than picked, because its code has a length, so `create`
  # looks the record up by that code and reports one that matches nothing.
  def test_it_resolves_a_typed_reference_and_rejects_one_that_matches_nothing
    Job.delete_all
    Location.delete_all
    code = ZIP.first!.code
    @session.post '/locations', params: { location: { zip_id: code } }

    assert_equal code, Location.sole.zip.code

    @session.post '/locations', params: { location: { zip_id: '00000' } }

    assert_includes body, '>ZIP code</label>'
    assert_includes body, 'maxlength="5" minlength="5" pattern="\d{5}"'
    assert_match %r{value="00000".*id="location_zip_id_error">Must exist}m, body
  end

private

  # A parent cannot be cleared with `delete_all` while its children point at it: that
  # is raw SQL, and skips the callbacks `dependent:` works through.
  def clear_contacts
    Booking.delete_all
    Message.delete_all
    Contact.delete_all
  end

  def body
    @session.response.body
  end
end
