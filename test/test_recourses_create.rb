require 'test_helper'
require 'action_dispatch/testing/integration'

# What `create` does with a record that saves and with one that does not.
class TestRecoursesCreate < Minitest::Test
  def setup
    @session = ActionDispatch::Integration::Session.new Rails.application
  end

  def test_it_saves_and_returns_to_the_index_with_a_notice
    Contact.delete_all
    @session.post '/contacts', params: { contact: { phone: '5552234567', name: 'Ada' } }

    assert_equal 303, @session.response.status
    assert_includes @session.response.headers['Location'], '/contacts'
    assert_equal 'Contact was created.', @session.request.flash[:notice]
    assert_equal 'Ada', Contact.sole.name
  end

  # A missing state fails `belongs_to`, which reports on :state, not :state_id, so
  # the message reaches the combobox only because both names are asked.
  def test_it_redraws_the_form_with_the_errors_beside_the_fields
    @session.post '/counties', params: { county: { fips: '9', name: '' } }

    assert_equal 422, @session.response.status
    assert_includes body, "<div class='toast theme-danger' role='alert'"
    assert_includes body, "<div class='toast-body'>County could not be created.</div>"
    assert_includes body, "class='form-control is-invalid combobox-toggle'"
    assert_includes body, "<small class='invalid-feedback' id='county_state_id_error'>Must exist"
    assert_includes body,
                    '<input aria-describedby="county_name_error" class="is-invalid form-control"'
    assert_includes body,
                    '<small class="invalid-feedback" id="county_name_error">Can&#39;t be blank'
  end

private

  def body
    @session.response.body
  end
end
